FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANDROID_SDK_ROOT=/root/android-sdk
ENV ANDROID_NDK_HOME=/root/android-sdk/ndk/android-ndk-r28
ENV PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"

RUN apt-get update && apt-get install -y \
    wget unzip git curl openjdk-17-jdk build-essential \
    ninja-build cmake make perl nasm

# SDK
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/tmp \
    && mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/latest \
    && cd $ANDROID_SDK_ROOT \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O sdk-tools.zip \
    && unzip sdk-tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools/tmp \
    && mv -v $ANDROID_SDK_ROOT/cmdline-tools/tmp/cmdline-tools/* $ANDROID_SDK_ROOT/cmdline-tools/latest \
    && rm -rf $ANDROID_SDK_ROOT/cmdline-tools/tmp \
    && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager "build-tools;34.0.0" "platforms;android-28" "platform-tools"

# NDK
RUN mkdir -p $ANDROID_SDK_ROOT/ndk \
    && cd $ANDROID_SDK_ROOT/ndk \
    && wget https://dl.google.com/android/repository/android-ndk-r28-linux.zip -O ndk.zip \
    && unzip ndk.zip \
    && rm ndk.zip

# Clone
RUN mkdir -p /root/build \
    && cd /root/build \
    && git clone https://gitlab.linphone.org/BC/public/bcg729.git \
    && cd bcg729 \
    && git checkout tags/1.1.1 -b v1.1.1

WORKDIR /root/build/bcg729

# Build
RUN for ARCH in armeabi-v7a arm64-v8a x86 x86_64; do \
      echo "Building bcg729 for $ARCH..."; \
      mkdir -p build/$ARCH && cd build/$ARCH; \
      cmake -G Ninja \
            -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake \
            -DANDROID_ABI=$ARCH \
            -DANDROID_PLATFORM=28 \
            -DCMAKE_ANDROID_STL_TYPE=c++_shared \
            -DCMAKE_INSTALL_PREFIX=/libs/$ARCH \
            ../..; \
      ninja && ninja install; cd ../..; \
    done

    
# Organize compiled files in /root/outputs
RUN mkdir -p /root/outputs \
&& cp -r /libs /root/outputs

# Set working directory
WORKDIR /root

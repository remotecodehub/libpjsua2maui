# Base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANDROID_SDK_ROOT=/root/android-sdk
ENV NDK_HOME=/root/android-sdk/ndk/
ENV ANDROID_NDK_HOME=/root/android-sdk/ndk/android-ndk-r21e
ENV PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
    curl \
    openjdk-17-jdk \
    build-essential \
    ninja-build \
    cmake \
    perl \
    nasm  

# Install Android SDK
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/tmp \
    &&  mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/latest \ 
    && cd $ANDROID_SDK_ROOT \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O sdk-tools.zip \
    && unzip sdk-tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools/tmp \
    && mv -v $ANDROID_SDK_ROOT/cmdline-tools/tmp/cmdline-tools/* $ANDROID_SDK_ROOT/cmdline-tools/latest \
    && rm -rf $ANDROID_SDK_ROOT/cmdline-tools/tmp \
    && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager "build-tools;34.0.0" "platforms;android-28" "platform-tools"

# Install Android NDK r28
RUN mkdir -p $NDK_HOME \
    && cd $NDK_HOME \
    && wget https://dl.google.com/android/repository/android-ndk-r21e-linux-x86_64.zip -O ndk.zip \
    && unzip ndk.zip -d $NDK_HOME \
    && rm ndk.zip

RUN mkdir -p /root/build \
    && cd /root/build \
    && git clone https://gitlab.linphone.org/BC/public/bcg729.git \
    && cd bcg729 \
    && git checkout tags/1.1.1 -b v1.1.1

# Compile bcg729 for all architectures
WORKDIR /root/build/bcg729

RUN for ARCH in armeabi-v7a arm64-v8a x86 x86_64; do \
      echo "Building bcg729 for $ARCH..."; \
      mkdir -p build/$ARCH && cd build/$ARCH; \
      cmake -DCMAKE_SYSTEM_NAME=Android \
            -DCMAKE_SYSTEM_VERSION=28 \
            -DCMAKE_ANDROID_ARCH_ABI=$ARCH \
            -DCMAKE_ANDROID_NDK=$ANDROID_NDK_HOME \
            -DCMAKE_ANDROID_STL_TYPE=c++_shared \
            -DCMAKE_INSTALL_PREFIX=/libs/$ARCH \
            ../..; \
       make && make install; cd ../..; \
    done
    
# Organize compiled files in /root/outputs
RUN mkdir -p /root/outputs \
&& cp -r /libs /root/outputs

# Set working directory
WORKDIR /root

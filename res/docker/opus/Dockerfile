# Base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANDROID_SDK_ROOT=/root/android-sdk
ENV ANDROID_NDK_ROOT=/root/android-sdk/ndk/r28/android-ndk-r28
ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_NDK_ROOT:$PATH
ENV NDK_ROOT=/root/android-sdk/ndk/r28
# Install dependencies
RUN apt-get update && apt-get install -y ninja-build \
    wget \
    unzip \
    git \
    curl \
    openjdk-17-jdk \
    build-essential \
    autoconf \
    automake \
    libtool \ 
    cmake 

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
RUN mkdir -p $NDK_ROOT \
    && cd $NDK_ROOT \
    && wget https://dl.google.com/android/repository/android-ndk-r28-linux.zip -O ndk.zip \
    && unzip ndk.zip -d $NDK_ROOT \
    && rm ndk.zip

WORKDIR /root/build/
RUN git clone https://gitlab.xiph.org/xiph/opus.git
 
WORKDIR /root/build/opus 
RUN git checkout v1.4 && git submodule update --init --recursive
ENV API=28
ENV TOOLCHAIN=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64
ENV ARCHS="armeabi-v7a arm64-v8a x86 x86_64" 
RUN echo `which ninja && ninja --version`
RUN mkdir -p /root/outputs && \
    for arch in armeabi-v7a arm64-v8a x86 x86_64; do \
      echo "Building Opus with CMake for $arch..." && \
      mkdir /root/build/opus/build-$arch && \
      cd /root/build/opus/build-$arch && \
      ABI=$arch && \
      cmake .. \
        -G Ninja \
        -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake \
        -DANDROID_ABI=$ABI \
        -DANDROID_PLATFORM=android-$API \
        -DCMAKE_BUILD_TYPE=Release \ 
        -DBUILD_SHARED_LIBS=OFF \
        -DOPUS_BUILD_PROGRAMS=OFF \
        -DOPUS_BUILD_TESTING=OFF \
        -DCMAKE_INSTALL_PREFIX=/root/outputs/$arch && \
      cmake --build . --target install;  \ 
    done

 
# Set working directory
WORKDIR /root

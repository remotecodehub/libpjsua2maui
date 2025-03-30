# Base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANDROID_SDK_ROOT=/root/android-sdk
ENV NDK_HOME=/root/android-sdk/ndk/
ENV ANDROID_NDK_HOME=/root/android-sdk/ndk/android-ndk-r28
ENV ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/r28
ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_NDK_HOME:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

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
    && wget https://dl.google.com/android/repository/android-ndk-r28-linux.zip -O ndk.zip \
    && unzip ndk.zip -d $NDK_HOME \
    && rm ndk.zip

# Clone OpenH264 repository
RUN mkdir -p /root/build \
    && cd /root/build \
    && git clone https://github.com/cisco/openh264.git \
    && cd openh264 \
    && git checkout tags/v2.3.0 -b v2.3.0

# Compile OpenH264 for all architectures
WORKDIR /root/build/openh264

RUN for ARCH in armeabi-v7a arm64-v8a x86 x86_64; do \
      case $ARCH in \
        armeabi-v7a) \
          TARGET=arm; ABI="arm-linux-androideabi"; TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
          CFLAGS="--sysroot=$TOOLCHAIN/sysroot -target armv7-none-linux-androideabi28 -D__ANDROID_API__=28 -fPIC"; \
          LDFLAGS="--sysroot=$TOOLCHAIN/sysroot -L$TOOLCHAIN/lib64 -L$TOOLCHAIN/sysroot/usr/lib/$ABI -lc -lm -lgcc -lstdc++"; \
          ;; \
        arm64-v8a) \
          TARGET=arm64; ABI="aarch64-linux-android"; TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
          CFLAGS="--sysroot=$TOOLCHAIN/sysroot -target aarch64-none-linux-android28 -D__ANDROID_API__=28 -fPIC"; \
          LDFLAGS="--sysroot=$TOOLCHAIN/sysroot -L$TOOLCHAIN/lib64 -L$TOOLCHAIN/sysroot/usr/lib/$ABI -lc -lm -lgcc -lstdc++"; \
          ;; \
        x86) \
          TARGET=x86; ABI="i686-linux-android"; TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
          CFLAGS="--sysroot=$TOOLCHAIN/sysroot -target i686-none-linux-android28 -D__ANDROID_API__=28 -fPIC"; \
          LDFLAGS="--sysroot=$TOOLCHAIN/sysroot -L$TOOLCHAIN/lib64 -L$TOOLCHAIN/sysroot/usr/lib/$ABI -lc -lm -lgcc -lstdc++"; \
          ;; \
        x86_64) \
          TARGET=x86_64; ABI="x86_64-linux-android"; TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
          CFLAGS="--sysroot=$TOOLCHAIN/sysroot -target x86_64-none-linux-android28 -D__ANDROID_API__=28 -fPIC"; \
          LDFLAGS="--sysroot=$TOOLCHAIN/sysroot -L$TOOLCHAIN/lib64 -L$TOOLCHAIN/sysroot/usr/lib/$ABI -lc -lm -lgcc -lstdc++"; \
          ;; \
      esac; \
      echo "Building OpenH264 for $ARCH..."; \
      make clean; \
      make OS=android ARCH=$TARGET TARGET=android NDKROOT=$ANDROID_NDK_HOME \
        APP_PLATFORM=android-28 APP_STL=c++_shared NDK_TOOLCHAIN_VERSION=clang \
        CC=$TOOLCHAIN/bin/clang CXX=$TOOLCHAIN/bin/clang++ LD=$TOOLCHAIN/bin/ld.lld \
        CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"  ; \
      make install PREFIX=/libs/$ARCH ; \
    done

# Set outputs directory
RUN mkdir -p /root/outputs \
    && cp -r /libs /root/outputs

# Working directory
WORKDIR /root 
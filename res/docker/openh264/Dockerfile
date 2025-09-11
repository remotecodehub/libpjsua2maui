# Base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANDROID_SDK_ROOT=/root/android-sdk
ENV NDK_HOME=/root/android-sdk/ndk/
ENV ANDROID_NDK_HOME=/root/android-sdk/ndk/android-ndk-r28b
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

# Install Android NDK r28b
RUN mkdir -p $NDK_HOME \
    && cd $NDK_HOME \
    && wget https://dl.google.com/android/repository/android-ndk-r28b-linux.zip -O ndk.zip \
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
RUN sed -e "/binaries: decdemo encdemo/ s/^#*/#/" -i ./build/platform-android.mk

# Wrapper for NASM w/ PIC support
RUN echo '#!/bin/sh\nexec /usr/bin/nasm -DX86_32_PICASM "$@"' > /usr/local/bin/nasm-pic \
    && chmod +x /usr/local/bin/nasm-pic

RUN for ARCH in armeabi-v7a arm64-v8a x86_64 x86; do \
  case $ARCH in \
    armeabi-v7a) \
      TARGET=arm; ABI="arm-linux-androideabi"; USE_ASM=Yes; \
      TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
      CC=$TOOLCHAIN/bin/armv7a-linux-androideabi28-clang; \
      CXX=$TOOLCHAIN/bin/armv7a-linux-androideabi28-clang++; \
      LD=$TOOLCHAIN/bin/armv7a-linux-androideabi28-clang++; \
      ;; \
    arm64-v8a) \
      TARGET=arm64; ABI="aarch64-linux-android"; USE_ASM=Yes; \
      TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
      CC=$TOOLCHAIN/bin/aarch64-linux-android28-clang; \
      CXX=$TOOLCHAIN/bin/aarch64-linux-android28-clang++; \
      LD=$TOOLCHAIN/bin/aarch64-linux-android28-clang++; \
      ;; \
    x86_64) \
      TARGET=x86_64; ABI="x86_64-linux-android"; USE_ASM=Yes; \
      TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
      CC=$TOOLCHAIN/bin/x86_64-linux-android28-clang; \
      CXX=$TOOLCHAIN/bin/x86_64-linux-android28-clang++; \
      LD=$TOOLCHAIN/bin/x86_64-linux-android28-clang++; \
      ;; \
    x86) \
      TARGET=x86; ABI="i686-linux-android"; USE_ASM=No; \
      TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
      CC=$TOOLCHAIN/bin/i686-linux-android28-clang; \
      CXX=$TOOLCHAIN/bin/i686-linux-android28-clang++; \
      LD=$TOOLCHAIN/bin/i686-linux-android28-clang++; \
      NASM=/usr/local/bin/nasm-pic; \
      NASMFLAGS="-DX86_32_PICASM"; \
      ;; \
  esac; \
  CFLAGS="--sysroot=$TOOLCHAIN/sysroot -target $ABI -D__ANDROID_API__=28 -fPIC"; \
  LDFLAGS="--sysroot=$TOOLCHAIN/sysroot -fPIC -Wl,-z,max-page-size=16384 -lc++_shared -lc -lm"; \
  echo "Building OpenH264 for $ARCH..."; \
  make clean || true; \
  find . -name '*.o' -delete || true; \
  make OS=android ARCH=$TARGET SYSROOT="$TOOLCHAIN/sysroot" TARGET=android NDKROOT=$ANDROID_NDK_HOME \
    APP_PLATFORM=android-28 APP_STL=c++_shared NDK_TOOLCHAIN_VERSION=clang \
    CC=$CC CXX=$CXX LD=$LD \
    CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" NASMFLAGS="$NASMFLAGS" NASM="$NASM" USE_ASM=$USE_ASM || exit 1; \
  echo "Installing OpenH264 for $ARCH..."; \
  make PREFIX=/libs/$ARCH \
    OS=android ARCH=$TARGET SYSROOT="$TOOLCHAIN/sysroot" TARGET=android NDKROOT=$ANDROID_NDK_HOME \
    APP_PLATFORM=android-28 APP_STL=c++_shared NDK_TOOLCHAIN_VERSION=clang \
    CC=$CC CXX=$CXX LD=$LD \
    CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" USE_ASM=$USE_ASM install || exit 1; \
  echo "Cleaning build artifacts for $ARCH..."; \
  make clean || true; \
  find . -name '*.o' -delete || true; \
done

# Set outputs directory
RUN mkdir -p /root/outputs \
    && cp -r /libs /root/outputs

# Working directory
WORKDIR /root 
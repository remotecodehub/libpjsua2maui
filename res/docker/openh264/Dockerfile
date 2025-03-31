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


# Clone OpenH264 repository
RUN mkdir -p /root/build \
    && cd /root/build \
    && git clone https://github.com/cisco/openh264.git \
    && cd openh264 \
    && git checkout tags/v2.3.0 -b v2.3.0

# Compile OpenH264 for all architectures
WORKDIR /root/build/openh264
RUN sed -e "/binaries: decdemo encdemo/ s/^#*/#/" -i ./build/platform-android.mk
#RUN sed -i 's|-gcc-toolchain $(GCC_TOOLCHAIN_PATH)||' ./build/platform-android.mk; \
    #cat ./build/platform-android.mk

RUN for ARCH in armeabi-v7a arm64-v8a x86 x86_64; do \ 
      case $ARCH in \
        armeabi-v7a) \
          TARGET=arm; ABI="arm-linux-androideabi"; TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
          CC=$TOOLCHAIN/bin/armv7a-linux-androideabi28-clang; \
          CXX=$TOOLCHAIN/bin/armv7a-linux-androideabi28-clang++; \
          LD=$TOOLCHAIN/bin/armv7a-linux-androideabi28-clang++; \
          CFLAGS="--sysroot=$TOOLCHAIN/sysroot -target armv7-none-linux-androideabi28 -D__ANDROID_API__=28 -fPIC"; \
          LDFLAGS="--sysroot=$TOOLCHAIN/sysroot -lc++_shared -lc -lm "; \
          ;; \
        arm64-v8a) \
          TARGET=arm64; ABI="aarch64-linux-android"; TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
          CC=$TOOLCHAIN/bin/aarch64-linux-android28-clang; \
          CXX=$TOOLCHAIN/bin/aarch64-linux-android28-clang++; \
          LD=$TOOLCHAIN/bin/aarch64-linux-android28-clang++; \
          CFLAGS="--sysroot=$TOOLCHAIN/sysroot -target aarch64-none-linux-android28 -D__ANDROID_API__=28 -fPIC"; \
          LDFLAGS="--sysroot=$TOOLCHAIN/sysroot -lc++_shared -lc -lm "; \
          ;; \
        x86) \
          TARGET=x86; ABI="i686-linux-android"; TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
          CC=$TOOLCHAIN/bin/i686-linux-android28-clang; \
          CXX=$TOOLCHAIN/bin/i686-linux-android28-clang++; \
          LD=$TOOLCHAIN/bin/i686-linux-android28-clang++; \
          CFLAGS="--sysroot=$TOOLCHAIN/sysroot -target i686-none-linux-android28 -D__ANDROID_API__=28 -fPIC"; \
          LDFLAGS="--sysroot=$TOOLCHAIN/sysroot -lc++_shared -lc -lm "; \
          ;; \
        x86_64) \
          TARGET=x86_64; ABI="x86_64-linux-android"; TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
          CC=$TOOLCHAIN/bin/x86_64-linux-android28-clang; \
          CXX=$TOOLCHAIN/bin/x86_64-linux-android28-clang++; \
          LD=$TOOLCHAIN/bin/x86_64-linux-android28-clang++; \
          CFLAGS="--sysroot=$TOOLCHAIN/sysroot -target x86_64-none-linux-android28 -D__ANDROID_API__=28 -fPIC"; \
          LDFLAGS="--sysroot=$TOOLCHAIN/sysroot -lc++_shared -lc -lm "; \
          ;; \
      esac; \
      echo "Building OpenH264 for $ARCH..."; \
      make clean || true; \
      echo "Cleaning previous builds for $ARCH..."; \
      find . -name '*.o' -delete || true; \  
      make OS=android ARCH=$TARGET SYSROOT="$TOOLCHAIN/sysroot" TARGET=android NDKROOT=$ANDROID_NDK_HOME \
        APP_PLATFORM=android-28 APP_STL=c++_shared NDK_TOOLCHAIN_VERSION=clang \
        CC=$CC CXX=$CXX LD=$LD \
        CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" || exit 1; \
      echo "Installing OpenH264 for $ARCH..."; \
      make PREFIX=/libs/$ARCH \
        OS=android ARCH=$TARGET SYSROOT="$TOOLCHAIN/sysroot" TARGET=android NDKROOT=$ANDROID_NDK_HOME \
        APP_PLATFORM=android-28 APP_STL=c++_shared NDK_TOOLCHAIN_VERSION=clang \
        CC=$CC CXX=$CXX LD=$LD \
        CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" install || exit 1; \
    done

# Set outputs directory
RUN mkdir -p /root/outputs \
    && cp -r /libs /root/outputs

# Working directory
WORKDIR /root 
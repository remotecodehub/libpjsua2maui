# Base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANDROID_SDK_ROOT=/root/android-sdk
ENV ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/r28
ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_NDK_ROOT:$PATH

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
    nasm \
    && apt-get clean

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
RUN mkdir -p $ANDROID_NDK_ROOT \
    && cd $ANDROID_NDK_ROOT \
    && wget https://dl.google.com/android/repository/android-ndk-r28-linux.zip -O ndk.zip \
    && unzip ndk.zip -d $ANDROID_NDK_ROOT \
    && rm ndk.zip

# Download OpenSSL source code
RUN mkdir -p /root/build \
    && cd /root/build \
    && wget https://www.openssl.org/source/openssl-1.1.1s.tar.gz \
    && tar -xzf openssl-1.1.1s.tar.gz \
    && rm openssl-1.1.1s.tar.gz

# Compile OpenSSL for all architectures
WORKDIR /root/build/openssl-1.1.1s

RUN for ARCH in armeabi-v7a arm64-v8a x86 x86_64; do \
      case $ARCH in \
        armeabi-v7a) \
          TARGET="android-arm"; ABI="arm-linux-androideabi"; TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64"; \
          ANDROID_ARCH="arch-arm"; CROSS_COMPILE="$TOOLCHAIN/bin/arm-linux-androideabi-"; \
          ;; \
        arm64-v8a) \
          TARGET="android-arm64"; ABI="aarch64-linux-android"; TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64"; \
          ANDROID_ARCH="arch-arm64"; CROSS_COMPILE="$TOOLCHAIN/bin/aarch64-linux-android-"; \
          ;; \
        x86) \
          TARGET="android-x86"; ABI="i686-linux-android"; TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64"; \
          ANDROID_ARCH="arch-x86"; CROSS_COMPILE="$TOOLCHAIN/bin/i686-linux-android-"; \
          ;; \
        x86_64) \
          TARGET="android-x86_64"; ABI="x86_64-linux-android"; TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64"; \
          ANDROID_ARCH="arch-x86_64"; CROSS_COMPILE="$TOOLCHAIN/bin/x86_64-linux-android-"; \
          ;; \
      esac; \
      echo "Building OpenSSL for $ARCH..."; \
      ./Configure $TARGET --prefix=/libs/$ARCH --openssldir=/libs/$ARCH; \
      make clean; \
      PATH="$TOOLCHAIN/bin:$PATH" make -j$(nproc) && make install_sw; \
    done

# Organize compiled files in /root/outputs
RUN mkdir -p /root/outputs \
    && cp -r /libs /root/outputs

# Set working directory
WORKDIR /root 
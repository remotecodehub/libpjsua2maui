# Base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANDROID_SDK_ROOT=/root/android-sdk
ENV NDK_HOME=/root/android-sdk/ndk/
ENV ANDROID_NDK_HOME=/root/android-sdk/ndk/android-ndk-r28
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
    && wget https://dl.google.com/android/repository/android-ndk-r28-linux.zip -O ndk.zip \
    && unzip ndk.zip -d $NDK_HOME \
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
          TARGET="android-arm"; \
          TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
          CC="$TOOLCHAIN/bin/armv7a-linux-androideabi28-clang"; \
          ;; \
        arm64-v8a) \
          TARGET="android-arm64"; \
          TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
          CC="$TOOLCHAIN/bin/aarch64-linux-android28-clang"; \
          ;; \
        x86) \
          TARGET="android-x86"; \
          TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
          CC="$TOOLCHAIN/bin/i686-linux-android28-clang"; \
          ;; \
        x86_64) \
          TARGET="android-x86_64"; \
          TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
          CC="$TOOLCHAIN/bin/x86_64-linux-android28-clang"; \
          ;; \
      esac; \
      echo "Building OpenSSL for $ARCH..."; \
      make clean || true; \
      PATH="$TOOLCHAIN/bin:$PATH" CC="$CC" ./Configure $TARGET no-shared --prefix=/libs/$ARCH --openssldir=/libs/$ARCH || cat configdata.pm; \
      PATH="$TOOLCHAIN/bin:$PATH" make -j$(nproc) && make install_sw; \
    done


# Organize compiled files in /root/outputs
RUN mkdir -p /root/outputs \
    && cp -r /libs /root/outputs

# Set working directory
WORKDIR /root
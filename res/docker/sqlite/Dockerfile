# Base image
FROM ubuntu:20.04

# Environment
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANDROID_SDK_ROOT=/root/android-sdk
ENV ANDROID_NDK_ROOT=/root/android-sdk/ndk/r28/android-ndk-r28
ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_NDK_ROOT:$PATH
ENV NDK_ROOT=/root/android-sdk/ndk/r28

# Install dependencies
RUN apt-get update && apt-get install -y \
    ninja-build \
    wget \
    unzip \
    git \
    curl \
    openjdk-17-jdk \
    build-essential \
    autoconf \
    automake \
    libtool \
    cmake \
    tcl

# Install Android SDK
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/tmp \
    && mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/latest \
    && cd $ANDROID_SDK_ROOT \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O sdk-tools.zip \
    && unzip sdk-tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools/tmp \
    && mv -v $ANDROID_SDK_ROOT/cmdline-tools/tmp/cmdline-tools/* $ANDROID_SDK_ROOT/cmdline-tools/latest \
    && rm -rf $ANDROID_SDK_ROOT/cmdline-tools/tmp \
    && yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager \
        "build-tools;34.0.0" \
        "platforms;android-28" \
        "platform-tools"

# Install Android NDK r28
RUN mkdir -p $NDK_ROOT \
    && cd $NDK_ROOT \
    && wget https://dl.google.com/android/repository/android-ndk-r28-linux.zip -O ndk.zip \
    && unzip ndk.zip -d $NDK_ROOT \
    && rm ndk.zip

# =========================
# BUILD SQLITE
# =========================

WORKDIR /root/build/

# Clone SQLite (official mirror)
RUN git clone https://github.com/sqlite/sqlite.git

WORKDIR /root/build/sqlite

# Use latest stable tag (opcional: fixar versão)
RUN git checkout version-3.45.1

ENV API=28
ENV TOOLCHAIN=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64
ENV ARCHS="armeabi-v7a arm64-v8a x86 x86_64"

RUN mkdir -p /root/outputs && \
    for arch in armeabi-v7a arm64-v8a x86 x86_64; do \
      echo "Building SQLite for $arch..." && \
      mkdir -p /root/build/sqlite/build-$arch && \
      cd /root/build/sqlite/build-$arch && \
      ABI=$arch && \
      TOOLCHAIN=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64 && \
      API=28 && \

      case "$arch" in \
        armeabi-v7a) TARGET=armv7a-linux-androideabi; HOST=arm-linux-androideabi; ;; \
        arm64-v8a)   TARGET=aarch64-linux-android; HOST=aarch64-linux-android; ;; \
        x86)         TARGET=i686-linux-android; HOST=i686-linux-android; ;; \
        x86_64)      TARGET=x86_64-linux-android; HOST=x86_64-linux-android; ;; \
      esac && \

      export CC=$TOOLCHAIN/bin/${TARGET}${API}-clang && \
      export AR=$TOOLCHAIN/bin/llvm-ar && \
      export RANLIB=$TOOLCHAIN/bin/llvm-ranlib && \
      export STRIP=$TOOLCHAIN/bin/llvm-strip && \

      echo "Using CC=$CC" && \

      ../configure \
        --host=$HOST \
        --disable-shared \
        --enable-static \
        --prefix=/root/outputs/$arch \
        CFLAGS="-Os -fPIC" && \

      make -j$(nproc) && \
      make install && \
      make clean; \
    done \

# Final working dir
WORKDIR /root
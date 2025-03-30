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
    autoconf \
    automake \
    libtool

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

# Download Opus source code
RUN mkdir -p /root/build \
&& cd /root/build \
&& git clone https://gitlab.xiph.org/xiph/opus.git \
&& cd opus \
&& git checkout tags/v1.4 -b v1.4

# Prepare for cross-compilation
WORKDIR /root/build/opus

RUN for ARCH in armeabi-v7a arm64-v8a x86 x86_64; do \
  case $ARCH in \
    armeabi-v7a) \
      TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
      HOST="arm-linux-androideabi"; \
      ;; \
    arm64-v8a) \
      TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
      HOST="aarch64-linux-android"; \
      ;; \
    x86) \
      TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
      HOST="i686-linux-android"; \
      ;; \
    x86_64) \
      TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; \
      HOST="x86_64-linux-android"; \
      ;; \
  esac; \
  echo "Building Opus for $ARCH..."; \
  ./autogen.sh; \
  ./configure --host=$HOST \
              --prefix=/libs/$ARCH \
              --enable-static \
              --disable-shared; \
  make -j$(nproc); \
  make install; \
done

# Organize compiled files in /root/outputs
RUN mkdir -p /root/outputs \
&& cp -r /libs /root/outputs

# Set working directory
WORKDIR /root

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

RUN export NDK_PROJECT_PATH=$(pwd)

RUN echo "Downloading Android.mk file from PjSip website ..." && \
  mkdir -p /root/build/opus/jni && \
  cd /root/build/opus/jni && \
  curl -k -O https://trac.pjsip.org/repos/raw-attachment/ticket/1904/Android.mk && \
  cd /root/build/opus && \
  $ANDROID_NDK_ROOT/android-ndk-r28/build/ndk-build NDK_DEBUG=1 V=1 -C /root/build/opus/jni APP_PLATFORM=android-28 APP_ABI="armeabi-v7a arm64-v8a x86 x86_64"  && \
  mkdir -p /root/build/opus/libs && \
  cp -r /root/build/opus/obj/local/* /root/build/opus/libs/ && \
  for arch in armeabi-v7a arm64-v8a x86 x86_64; do \
    echo "Copying Opus file for target arch $arch ..." && \
    mkdir -p /root/build/opus/libs/$arch/lib && \
    mv /root/build/opus/libs/$arch/*.so /root/build/opus/libs/$arch/lib/ || true && \
    mkdir -p /root/build/opus/libs/$arch/include/opus && \
    cp /root/build/opus/include/* /root/build/opus/libs/$arch/include/opus/ ; \
  done
  
# Organize compiled files in /root/outputs
RUN mkdir -p /root/outputs \
&& cp -r /libs /root/outputs

# Set working directory
WORKDIR /root

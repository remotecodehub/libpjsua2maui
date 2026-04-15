FROM ubuntu:20.04

LABEL org.opencontainers.image.version="0.0.1"
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.title="libpjsua2maui-android-builder-tools"
LABEL org.opencontainers.image.description="Base image for building PJSIP dependencies (OpenSSL, Opus, SQLite, OpenH264, bcg729) for Android"
LABEL org.opencontainers.image.source="https://github.com/remotecodehub/libpjsua2maui"
LABEL org.opencontainers.image.authors="Weslley Luiz"
LABEL org.opencontainers.image.licenses="MIT"


ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_NDK_HOME=/opt/android-ndk
ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

# deps unificadas
RUN apt-get update && apt-get install -y \
    wget unzip git curl \
    build-essential \
    ninja-build cmake make \
    autoconf automake libtool \
    openjdk-17-jdk \
    perl nasm tcl \
    pkg-config

# Android SDK
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    cd /tmp && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O tools.zip && \
    unzip tools.zip -d tmp && \
    mv tmp/cmdline-tools/* $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    yes | sdkmanager "platform-tools" "platforms;android-28"

# Android NDK r28
RUN mkdir -p $ANDROID_NDK_HOME && \
    cd /tmp && \
    wget https://dl.google.com/android/repository/android-ndk-r28-linux.zip && \
    unzip android-ndk-r28-linux.zip && \
    mv android-ndk-r28/* $ANDROID_NDK_HOME

WORKDIR /build
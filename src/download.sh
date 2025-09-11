#!/bin/sh
set -e
TARGET_ANDROID=0
TARGET_IOS=0
TARGET_WINDOWS=0
TARGET_MACOSX=0
CLEAN_ANDROID=0
CLEAN_IOS=0
CLEAN_WINDOWS=0
CLEAN_MACOSX=0
function downloadAndroid () {
    if [ "$VERSION" == "v" ]; then 
        echo "please set a version with 'v=*' parameter"
        exit 1
    fi
    curl -L -o ./libpjsua2.maui.so.tar.gz https://github.com/weslleymurdock/libpjsua2-android/releases/download/v2.14.1.1/libpjsua2.tar.gz
    tar -xzvf libpjsua2.maui.so.tar.gz 
    mkdir -p ./libpjsua2.maui.android/org/pjsip
    mkdir -p ./libpjsua2.maui.android/pjsua2maui
    mkdir -p ./libpjsua2.so/lib/
    mv -v ./home/runner/libpjsua2/lib/libpjsua2.maui.android/* ./libpjsua2.maui.android/pjsua2maui
    rm -rf ./home/runner/libpjsua2/lib/java/org/pjsip/pjsua2
    mv -v ./home/runner/libpjsua2/lib/java/org/pjsip/* ./libpjsua2.maui.android/org/pjsip/
    mv -v ./home/runner/libpjsua2/lib/* ./libpjsua2.runtime.android/lib/
   
}

function downloadiOS () {
    echo "iOS ..."
    curl -L -o ./libpjsua2.maui.a.tar.gz https://github.com/weslleymurdock/libpjsua2-ios/releases/download/v2.14.1.1/libpjsua2.tar.gz
    tar -xzvf libpjsua2.maui.a.tar.gz
    mkdir -p ./libpjsua2.maui.ios/pjsua2maui
    mkdir -p ./libpjsua2.runtime.ios/lib/arm64 
    mkdir -p ./libpjsua2.runtime.ios/lib/x86_64 
    mv -v ./libpjsua2/lib/pjsua2maui/pjsua2/* ./libpjsua2.maui.ios/pjsua2maui
    mv -v ./libpjsua2/lib/arm64/libpjsua2.a  ./libpjsua2.runtime.ios/lib/arm64
    mv -v ./libpjsua2/lib/x86_64/libpjsua2.a  ./libpjsua2.runtime.ios/lib/x86_64 
    rm -rf ./libpjsua2 libpjsua2.maui.a.tar.gz
}

function downloadMac () {

     echo "not implemented"
}

function downloadWin () {
     echo "not implemented"
     
}

function setupTargetsToClean () {
     if [ "$TARGET_ANDROID" == "1" ]; then
        CLEAN_ANDROID=1
    fi

    if [ "$TARGET_IOS" == "1" ]; then
        CLEAN_IOS=1
    fi

    if [ "$TARGET_WINDOWS" == "1" ]; then
        CLEAN_WINDOWS=1
    fi

    if [ "$TARGET_MACOSX" == "1" ]; then
        CLEAN_MACOSX=1
    fi
     
}


for i in "$@"; do
    case $i in
    --android | android)
    TARGET_ANDROID=1
    shift
    ;;
    --ios | ios)
    TARGET_IOS=1
    shift
    ;;
    --macos | osx)
    TARGET_MACOSX=1
    shift
    ;;
    --windows | win)
    TARGET_WINDOWS=1
    shift
    ;;
    --clean | clean)
    setupTargetsToClean
    shift
    ;;
    *)
    ;;
    esac
done

if [ "$TARGET_ANDROID" == "1" ]; then
    downloadAndroid
fi

if [ "$TARGET_IOS" == "1" ]; then
    downloadiOS
fi

if [ "$TARGET_WINDOWS" == "1" ]; then
    downloadWin
fi

if [ "$TARGET_MACOSX" == "1" ]; then
    downloadMac
fi

echo "done"
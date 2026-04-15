#!/bin/bash
set -e

docker build -t ghcr.io/remotecodehub/libpjsua2maui/pjsip-builder-tools:$1 . --build-arg "BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

docker push ghcr.io/remotecodehub/libpjsua2maui/pjsip-builder-tools:$1

docker build -t ghcr.io/remotecodehub/libpjsua2maui/pjsip-builder-tools:latest . --build-arg "BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

docker push ghcr.io/remotecodehub/libpjsua2maui/pjsip-builder-tools:latest

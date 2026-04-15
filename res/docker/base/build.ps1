Param (
    [Parameter(Mandatory=$true)]
    [Alias("v")]
    [string]
    $version
)

docker build -t ghcr.io/remotecodehub/libpjsua2maui/pjsip-builder-tools:$version . --build-arg "BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

docker push ghcr.io/remotecodehub/libpjsua2maui/pjsip-builder-tools:$version

docker build -t ghcr.io/remotecodehub/libpjsua2maui/pjsip-builder-tools:latest . --build-arg "BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

docker push ghcr.io/remotecodehub/libpjsua2maui/pjsip-builder-tools:latest

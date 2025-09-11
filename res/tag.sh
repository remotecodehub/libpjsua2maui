#!/bin/bash
set -e

export VERSION="v"
 
function release_tag () {

    if [ "$VERSION" == "v" ]; then 
        echo "please set a version with 'v=*' parameter"
        exit 1
    fi
     
    git tag $VERSION
    git push origin --tags
}

function reset_tag () {
    echo "git tag -d ${VERSION}"
    git tag -d $VERSION
    
    echo "git push --delete origin ${VERSION}"
    git push --delete origin $VERSION
}


for i in "$@"; do
    case $i in
    --version=*| v=*)
    VERSION_NUMBERS="${i#*=}"
    VERSION+="${VERSION_NUMBERS}"
    shift
    ;;
    --reset)
    reset_tag 
    shift
    ;;
    --release)
    release_tag
    shift
    ;;
    --help)
    show_help
    shift
    ;;
    *)
    ;;
    esac
done

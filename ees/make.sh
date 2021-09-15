#!/bin/bash

# IMAGE_NAME="postlux-ict-awx-ee"
# IMAGE_VERSION="0.0.1"
# REGISTRY="harbor-prod.dt.ept.lu/awx-ees"

IMAGE_VERSION="${IMAGE_VERSION:-"0.0.1"}"
REGISTRY="${REGISTRY:-"harbor.ptech.lu/awx-ees"}"


# Usage
function usage() {
    echo "Usage: $(basename ${0}) {all|build|tag|push} <ee path>"
    exit
}

# Setup
# $1: Execution environment path
function setup() {
    [[ ! -d "${1}" ]] && echo "Error: no such execution environment: '${1}'" && usage
    IMAGE_NAME=$(basename ${1})
    cd "${1}"
}

# Build the given execution environment.
# $1: Execution environment path
function build() {
    echo "Building ${IMAGE_NAME}:${IMAGE_VERSION}"
    ansible-builder build \
        --container-runtime=docker \
        --verbosity 3 \
        -t ${IMAGE_NAME}:${IMAGE_VERSION}
}

function tag() {
    echo "Tagging ${IMAGE_NAME}:${IMAGE_VERSION}"
    docker tag ${IMAGE_NAME}:${IMAGE_VERSION} ${REGISTRY}/${IMAGE_NAME}:${IMAGE_VERSION}
}

function push() {
    echo "Publishing ${IMAGE_NAME}:${IMAGE_VERSION}"
    docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_VERSION}
}

case $1 in
    all)    shift; setup "${1}"; build; tag; push;;
    build)  shift; setup "${1}"; build;;
    tag)    shift; setup "${1}"; tag;;
    push)   shift; setup "${1}"; push;;
    *)      usage;;
esac

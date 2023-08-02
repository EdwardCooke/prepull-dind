#!/bin/bash

echo "Verify the buildx container is correct"
docker buildx rm builder --keep-state 1> /dev/null 2> /dev/null
docker buildx create --name builder \
    --driver docker-container \
    --buildkitd-flags '--allow-insecure-entitlement security.insecure --allow-insecure-entitlement network.host'

echo "Building the image"
docker buildx build \
    --allow security.insecure \
    --output type=docker \
    -t mydind \
    --builder builder \
    --progress=plain \
    .

echo "Running the image, mydind"
docker run -it --rm --privileged --name dind mydind

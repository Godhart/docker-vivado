#!/bin/bash

echo "*" > .dockerignore
echo "!install_config.txt" >> .dockerignore

docker build -t "vivado-install" \
-f Dockerfile.vivado-install \
--build-arg USER_ID=$(id -u) .

echo "*" > .dockerignore
docker build -t "vivado" \
-f Dockerfile.vivado \
--build-arg USER_ID=$(id -u) .

# TODO: export as single image


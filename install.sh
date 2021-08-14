#!/bin/bash

echo "*" > .dockerignore
echo "!wi_authentication_key" >> .dockerignore
echo "!install_config.txt" >> .dockerignore

docker build -t "vivado-install" \
-f Dockerfile.vivado_install \
--build-arg USER_ID=$(id -u) .

echo "*" > .dockerignore
docker build -t "vivado" \
-f Dockerfile.vivado \
--build-arg USER_ID=$(id -u) .

# TODO: export as single image


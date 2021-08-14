#!/bin/bash

echo "*" > .dockerignore
echo "!auth.sh" >> .dockerignore

docker build -t "vivado-credential" \
-f Dockerfile.credential \
--build-arg USER_ID=$(id -u) .

docker run --rm -i -t -v "$(pwd)":/home/vivado/workspace "vivado-credential" /bin/bash /tmp/auth.sh
# docker rmi --force vivado-credential


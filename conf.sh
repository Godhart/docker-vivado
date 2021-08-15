#!/bin/bash

echo "*" > .dockerignore
echo "!auth.sh" >> .dockerignore

docker build -t "vivado-conf" \
-f Dockerfile.vivado-conf \
--build-arg USER_ID=$(id -u) .

docker run --rm -i -t -v "$(pwd)":/home/vivado/workspace "vivado-conf" /bin/bash /tmp/auth.sh

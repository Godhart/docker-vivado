#!/bin/bash

docker container rm --force vivado-export
docker run --name vivado-export vivado echo
docker export vivado-export > vivado.tar
docker container rm --force vivado-export


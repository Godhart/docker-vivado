#!/bin/bash

VIVADO_BIN=Distribs/Xilinx_Unified_2020.1_0602_1208

echo "*" > .dockerignore
echo "!$VIVADO_BIN" >> .dockerignore
echo "!$VIVADO_BIN/**/*" >> .dockerignore

docker build -t "vivado-distr" \
-f Dockerfile.vivado_distr \
--build-arg VIVADO_BIN=$VIVADO_BIN .


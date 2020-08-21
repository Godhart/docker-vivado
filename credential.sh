#!/bin/bash

VIVADO_BIN=Xilinx_Unified_2020.1_0602_1208_Lin64.bin

chmod +x $VIVADO_BIN

docker build -t "vivado-credential" -f Dockerfile.credential .

docker run -i -t -v "$(pwd)":/workspace "vivado-credential" /bin/bash -c /tmp/auth.sh
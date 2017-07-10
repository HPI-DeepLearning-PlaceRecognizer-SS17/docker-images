#!/bin/bash
set -e

# Bleeding edge for adrian
echo ""
echo "Building mxnet:python3-mxnetMaster"
echo ""
docker build --build-arg mxnetInstallTag=master -t mxnet:python3-mxnetMaster .

# Stable bleeding edge (for visual backprop)
echo ""
echo "Building mxnet:python3-mxnet0.10.0"
echo ""
docker build --build-arg mxnetInstallTag=v0.10.0 -t mxnet:python3-mxnet0.10.0 .

# mxnet 0.9.5 is tested to work with SSD
echo ""
echo "Building mxnet:python3-mxnet0.9.5"
echo ""
docker build --build-arg mxnetInstallTag=v0.9.5 -t mxnet:python3-mxnet0.9.5 .


#!/bin/bash

set -ex

build-koji.sh
setup.sh

IP=$(find-ip.py)

echo "Starting HTTPd on ${IP}"
httpd -D FOREGROUND

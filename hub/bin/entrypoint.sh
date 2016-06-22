#!/bin/bash

set -ex

build-koji.sh
setup.sh

mkdir -p /usr/lib/koji-hub-plugins
curl https://raw.githubusercontent.com/release-engineering/koji-containerbuild/master/koji_containerbuild/plugins/hub_containerbuild.py -o /usr/lib/koji-hub-plugins/hub_containerbuild.py

IP=$(find-ip.py)

echo "Starting HTTPd on ${IP}"
httpd -D FOREGROUND

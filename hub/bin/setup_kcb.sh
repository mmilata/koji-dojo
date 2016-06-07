#!/bin/bash

# Download latest k-cb plugin
curl https://raw.githubusercontent.com/release-engineering/koji-containerbuild/master/koji_containerbuild/plugins/hub_containerbuild.py -o /usr/lib/koji-hub-plugins/hub_containerbuild.py

#!/bin/bash

set -ex

yum -y install git python-setuptools epel-release
yum -y localinstall /opt/koji/noarch/koji-hub* /opt/koji/noarch/koji-builder-*.rpm

# TODO: the guide requires httpd to be restarted on koji hub

OSBS_SOURCE=${OSBS_REMOTE:-https://github.com/projectatomic/osbs-client.git}
OSBS_GITBRANCH=${OSBS_BRANCH:-master}

KCB_SOURCE=${KCB_REMOTE:-https://github.com/release-engineering/koji-containerbuild.git}
KCB_GITBRANCH=${KCB_BRANCH:-develop}

if [ -n "${BUILDROOT_INITIAL_IMAGE}" ]; then
  sed -i "s,build_image = .*,build_image = $BUILDROOT_IMAGE,g" /etc/osbs/osbs.conf
fi

# Install osbs-client
rm -rf ~/osbs-client
git clone $OSBS_SOURCE ~/osbs-client
cd ~/osbs-client
git checkout $OSBS_GITBRANCH
git rev-parse HEAD
python setup.py install
mkdir -p /usr/share/osbs
cp inputs/* /usr/share/osbs

# Install koji-containerbuild
rm -rf ~/koji-containerbuild
git clone $KCB_SOURCE ~/koji-containerbuild
cd ~/koji-containerbuild
git checkout $KCB_GITBRANCH
git rev-parse HEAD
# Remove install_requires
sed -i -e '/"koji",/d' -e '/"osbs",/d' setup.py
python setup.py install
cp koji_containerbuild/plugins/builder_containerbuild.py /usr/lib/koji-builder-plugins/builder_containerbuild.py

# Replace koji-client config with the one for koji-builder
cp /etc/kojid/kojid-builder.conf /etc/kojid/kojid.conf

# Add a new host
koji -c /opt/koji-clients/kojiadmin/config add-host $(hostname) x86_64 || true
koji -c /opt/koji-clients/kojiadmin/config add-host-to-channel $(hostname) container --new || true

# Start koji builder
/usr/sbin/kojid -f --force-lock

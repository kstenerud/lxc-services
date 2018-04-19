#!/bin/bash

# KLM server container for LXD
#
# https://forums.mydigitallife.net/threads/emulated-kms-servers-on-non-windows-platforms.50234/
# https://github.com/Wind4/vlmcsd
# https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys

set -eu

SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

CONTAINER_NAME=vlmcsd-builder

lxc launch images:alpine/3.7 $CONTAINER_NAME
sleep 1
lxc exec $CONTAINER_NAME -- apk add build-base gcc abuild binutils cmake git

# Overlay
pushd "$SCRIPT_HOME/build-fs"
tar cf - . | lxc exec $CONTAINER_NAME -- tar xf - -C /
popd

lxc exec $CONTAINER_NAME -- /root/install_vlmcsd.sh

lxc file pull vlmcsd-builder/root/vlmcsd/bin/vlmcs fs/usr/sbin/
lxc file pull vlmcsd-builder/root/vlmcsd/bin/vlmcsd fs/usr/sbin/

lxc delete --force $CONTAINER_NAME


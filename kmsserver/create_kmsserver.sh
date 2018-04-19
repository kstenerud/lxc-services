#!/bin/bash

# KLM server container for LXD
#
# https://forums.mydigitallife.net/threads/emulated-kms-servers-on-non-windows-platforms.50234/
# https://github.com/Wind4/vlmcsd
# https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys

set -eu

SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

# Configuration
CONTAINER_NAME=kmsserver

# Base image
lxc launch images:alpine/3.7 $CONTAINER_NAME

# Workaround for missing tty errors
lxc exec $CONTAINER_NAME -- sed -i 's/^tty/#tty/g' /etc/inittab
lxc restart $CONTAINER_NAME
sleep 1

# Overlay
pushd "$SCRIPT_HOME/fs"
tar cf - . | lxc exec $CONTAINER_NAME -- tar xf - -C /
popd

# Services
lxc exec $CONTAINER_NAME -- rc-update add vlmcsd
lxc exec $CONTAINER_NAME -- rc-service vlmcsd start


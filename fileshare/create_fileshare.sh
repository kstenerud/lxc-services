#!/bin/bash

# NFS and SMB file server container for LXD
#
# To mount and NFS share:
# mount -t nfs host:/mnt/shared /client/side/mount/path


set -eu

SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

# Configuration
CONTAINER_NAME=fileshare
SHARED_DIRECTORY=/mnt/shared

# Base image
lxc launch images:alpine/3.7 $CONTAINER_NAME
lxc exec $CONTAINER_NAME -- sed -i 's/^tty/#tty/g' /etc/inittab

# Privileged container (for NFS)
lxc config set $CONTAINER_NAME security.privileged true
lxc profile set default raw.apparmor "mount fstype=nfs,
mount fstype=nfs4,
mount fstype=nfsd,
mount fstype=rpc_pipefs,"
lxc restart $CONTAINER_NAME

# Shared directory
lxc exec $CONTAINER_NAME -- mkdir /mnt/shared
lxc config device add $CONTAINER_NAME shared disk source="$SHARED_DIRECTORY" path=/mnt/shared

# Install software (need to sleep so that apk doesn't barf)
sleep 1
lxc exec $CONTAINER_NAME -- apk add samba nfs-utils avahi dbus
pushd "$SCRIPT_HOME/fs"
tar cf - . | lxc exec $CONTAINER_NAME -- tar xf - -C /
popd

# Services
lxc exec $CONTAINER_NAME -- rc-update add dbus
lxc exec $CONTAINER_NAME -- rc-service dbus start
lxc exec $CONTAINER_NAME -- rc-update add samba
lxc exec $CONTAINER_NAME -- rc-service samba start
lxc exec $CONTAINER_NAME -- rc-update add avahi-daemon
lxc exec $CONTAINER_NAME -- rc-service avahi-daemon start
lxc exec $CONTAINER_NAME -- rc-update add nfs
lxc exec $CONTAINER_NAME -- rc-service nfs start


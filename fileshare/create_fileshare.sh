#!/bin/bash

# NFS and SMB file server container for LXD
#
# To mount and NFS share:
# mount -t nfs host:/mnt/shared /client/side/mount/path


set -eu

# Configuration
CONTAINER_NAME=fileshare
SHARED_DIRECTORY=/var/log

# Base image
lxc launch images:alpine/3.7 $CONTAINER_NAME

# Privileged container (for NFS)
lxc config set $CONTAINER_NAME security.privileged true
lxc profile set default raw.apparmor "mount fstype=nfs,
mount fstype=nfs4,
mount fstype=nfsd,
mount fstype=rpc_pipefs,"
lxc restart $CONTAINER_NAME

# Shared directory
lxc exec $CONTAINER_NAME mkdir /mnt/shared
lxc config device add $CONTAINER_NAME shared disk source="$SHARED_DIRECTORY" path=/mnt/shared

# Install software (need to sleep so that apk doesn't barf)
sleep 1
lxc exec $CONTAINER_NAME apk add samba nfs-utils
pushd fs
tar cf - . | lxc exec $CONTAINER_NAME -- tar xf - -C /
popd

# Services
lxc exec $CONTAINER_NAME rc-update add samba
lxc exec $CONTAINER_NAME rc-service samba start
lxc exec $CONTAINER_NAME rc-update add nfs
lxc exec $CONTAINER_NAME rc-service nfs start


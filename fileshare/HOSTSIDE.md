Host-Side Configuration
=======================

Bind Mounts
-----------

The fileshare container assumes you'll be sharing whatever's in /mnt/shared. You can bind-mount any directory to it or its subdirs

/etc/fstab:

    /original/path              /new/path                none    bind    0 0
    /original/path              /new/path                none    bind,ro 0 0

Client Side NFS Mount
---------------------

/etc/fstab:

    fileshare:/mnt/shared /client/mount/path  nfs rsize=8192,wsize=8192,timeo=14,intr


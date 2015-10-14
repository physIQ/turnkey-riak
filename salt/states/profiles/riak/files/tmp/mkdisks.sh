#!/bin/bash

disks="/dev/disk/by-id/google-tsSSD /dev/disk/by-id/google-tsMagnetic"

# Make sure disks exist
for disk in $disks; do
  if [ ! -L $disk ]; then
     echo "DISK ${disk} DOES NOT EXIST."
     exit 1
  fi
done

# Partition disks and create filesystem
for disk in $disks; do
  echo "n
p
1


w
"|fdisk $disk
  partprobe $disk; sleep 1
  mkfs.xfs ${disk}-part1
done

# Create fstab entries and mount disks
echo "/dev/disk/by-id/google-tsSSD-part1  /opt/riak/fast xfs noatime,nobarrier,logbufs=8,logbsize=256k,allocsize=2M 1 2" >> /etc/fstab
echo "/dev/disk/by-id/google-tsMagnetic-part1  /opt/riak/slow xfs noatime,nobarrier,logbufs=8,logbsize=256k,allocsize=2M  1 2" >> /etc/fstab

mount /opt/riak/fast
mount /opt/riak/slow

mkdir /opt/riak/fast/leveldb
mkdir /opt/riak/slow/leveldb

chown -R riak:riak /opt/riak

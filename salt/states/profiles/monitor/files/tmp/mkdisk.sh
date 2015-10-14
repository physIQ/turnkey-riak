#!/bin/bash

disks="/dev/disk/by-id/google-backup"

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
echo "/dev/disk/by-id/google-backup-part1  /backup xfs noatime,nobarrier,logbufs=8,logbsize=256k,allocsize=2M 1 2" >> /etc/fstab

mount /backup
if [ $? -ne 0 ]; then
	echo "FAILED TO MOUNT /BACKUP"
	exit 1
fi

mkdir /backup/bacula

chown root:root /backup/bacula
chmod 700 /backup/bacula

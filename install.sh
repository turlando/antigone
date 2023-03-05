#!/bin/sh
set -eu

# Incomplete documentation-script to the system installation and initial
# configuration.

# System installation
# ===================

# Prepare system drives
# ~~~~~~~~~~~~~~~~~~~~~

SYSTEM_DISK_1=/dev/disk/by-id/ata-Lexar__SSD_NS100_512GB_MJ9527016149
SYSTEM_DISK_2=/dev/disk/by-id/ata-Lexar__SSD_NS100_512GB_MJ9527016260

sgdisk --zap-all $SYSTEM_DISK_1
sgdisk --zap-all $SYSTEM_DISK_2

parted --script $SYSTEM_DISK_1 \
       mklabel gpt             \
       mkpart grub-1    1 2M   \
       mkpart boot-1   2M 4G   \
       mkpart system-1 4G 100% \
       set 1 bios_grub on

parted --script $SYSTEM_DISK_2 \
       mklabel gpt             \
       mkpart grub-2    1 2M   \
       mkpart boot-2   2M 4G   \
       mkpart system-2 4G 100% \
       set 1 bios_grub on

BOOT_PART_1=/dev/disk/by-partlabel/boot-1
BOOT_PART_2=/dev/disk/by-partlabel/boot-2

SYSTEM_PART_1=/dev/disk/by-partlabel/system-1
SYSTEM_PART_2=/dev/disk/by-partlabel/system-2

mkfs.ext4 -L boot-1 $BOOT_PART_1
mkfs.ext4 -L boot-2 $BOOT_PART_2

# 80% of 472GiB which is the available space
SYSTEM_POOL_QUOTA="380G"

zpool create                                        \
      -m none                                       \
      -o ashift=12                                  \
      -o altroot=/mnt                               \
      -O quota=$SYSTEM_POOL_QUOTA                   \
      -O canmount=off                               \
      -O checksum=fletcher4                         \
      -O compression=zstd                           \
      -O xattr=sa                                   \
      -O normalization=formD                        \
      -O atime=off                                  \
      -O encryption=aes-256-gcm                     \
      -O keyformat=passphrase -O keylocation=prompt \
      system                                        \
      mirror                                        \
      $SYSTEM_PART_1 $SYSTEM_PART_2

zfs create               \
    -o mountpoint=legacy \
    system/nix

zfs create               \
    -o acltype=posixacl  \
    -o mountpoint=legacy \
    system/root

zfs snapshot             \
    system/root@empty

zfs create               \
    -o acltype=posixacl
    -o mountpoint=legacy
    system/state

zfs create               \
    system/home

zfs create               \
    -o acltype=posixacl  \
    -o mountpoint=legacy \
    system/home/tancredi

# Mount partitions
# ~~~~~~~~~~~~~~~~

mkdir -p /mnt
mount -t zfs system/root /mnt 

mkdir -p /mnt/boot/1
mkdir -p /mnt/boot/2
mount -t ext4 $BOOT_PART_1 /mnt/boot/1
mount -t ext4 $BOOT_PART_2 /mnt/boot/2

mkdir -p /mnt/nix
mount -t zfs system/nix /mnt/nix

mkidr -p /mnt/var/state
mount -t zfs system/state /mnt/var/state

mkdir -p /mnt/home/tancredi
mount -t zfs system/home/tancredi /mnt/home/tancredi

# Install NixOS
# ~~~~~~~~~~~~~

# The following part is wrong and it is here just for reference.
# TODO: replace it with the commands to perform a system installation from
# the configuration contained in this repository.
nixos-generate-config --root /mnt
nixos-install

# How to boot
# ===========
#
# SSH into the initrd, then run
#    zpool import -a  # If there are multiple pools.
#    zfs load-key -a
#    pkill zfs        # To kill the process asking for a password at the tty
#                     # and to continue the boot process.

# Services storage
# ================

zfs create          \
    system/services

mkdir -p /var/services

# Quassel
# ~~~~~~~

zfs create                  \
    -o acltype=posixacl     \
    -o mountpoint=legacy    \
    system/services/quassel

mkdir -p /var/services/quassel
mount -t zfs system/services/quassel /var/services/quassel

# Syncthing
# ~~~~~~~~~

zfs create                    \
    -o acltype=posixacl       \
    -o mountpoint=legacy      \
    system/services/syncthing

mkdir -p /var/services/syncthing
mount -t zfs system/services/syncthing /var/services/syncthing

# Storage
# =======

STORAGE_DISK_1=/dev/disk/by-id/ata-HGST_HUS724040ALA640_PN1334PBJMA8AS
STORAGE_DISK_2=/dev/disk/by-id/ata-HGST_HUS724040ALA640_PN1334PBJN6DGS
STORAGE_DISK_3=/dev/disk/by-id/ata-HGST_HUS724040ALA640_PN1334PBJX3R3S
STORAGE_DISK_4=/dev/disk/by-id/ata-HGST_HUS724040ALA640_PN2334PBJTM5GT

# 80% of 7.2TiB
STORAGE_POOL_QUOTA="5800G"

sgdisk --zap-all $STORAGE_DISK_1
sgdisk --zap-all $STORAGE_DISK_2
sgdisk --zap-all $STORAGE_DISK_3
sgdisk --zap-all $STORAGE_DISK_4

zpool create                                        \
      -m none                                       \
      -o ashift=12                                  \
      -o altroot=/mnt                               \
      -O quota=$STORAGE_POOL_QUOTA                  \
      -O canmount=off                               \
      -O checksum=fletcher4                         \
      -O compression=zstd                           \
      -O xattr=sa                                   \
      -O normalization=formD                        \
      -O atime=off                                  \
      -O encryption=aes-256-gcm                     \
      -O keyformat=passphrase -O keylocation=prompt \
      storage                                       \
      mirror $STORAGE_DISK_1 $STORAGE_DISK_2        \
      mirror $STORAGE_DISK_3 $STORAGE_DISK_4

# Books
# ~~~~~

zfs create               \
    -o acltype=posixacl  \
    -o mountpoint=legacy \
    storage/books

mkdir -p /mnt/storage/books
mount -t zfs storage/books /mnt/storage/books
chown root:storage /mnt/storage/books
chmod g+s /mnt/storage/books
setfacl -m g:storage:rwX /mnt/storage/books

# Music
# ~~~~~

zfs create storage/music

# Electronic
# ----------

zfs create               \
    -o acltype=posixacl  \
    -o mountpoint=legacy \
    storage/music/electronic

mkdir -p /mnt/storage/music/electronic
mount -t zfs storage/music/electronic /mnt/storage/music/electronic
chown root:storage /mnt/storage/music/electronic
chmod g+s /mnt/storage/music/electronic
setfacl -m g:storage:rwX /mnt/storage/music/electronic

# Backup
# ======

# 80% of 10.9T
BACKUP_POOL_QUOTA="8700G"
BACKUP_DISK=/dev/disk/by-id/usb-WD_Elements_25A3_394C473334593841-0:0

zpool create                                        \
      -m none                                       \
      -o ashift=12                                  \
      -o altroot=/mnt                               \
      -O quota=$BACKUP_POOL_QUOTA                   \
      -O canmount=off                               \
      -O checksum=fletcher4                         \
      -O compression=zstd                           \
      -O xattr=sa                                   \
      -O normalization=formD                        \
      -O atime=off                                  \
      -O encryption=aes-256-gcm                     \
      -O keyformat=passphrase -O keylocation=prompt \
      backup                                        \
      $BACKUP_DISK

zfs create backup/system
zfs create backup/system/services
zfs create backup/storage
zfs create backup/storage/music

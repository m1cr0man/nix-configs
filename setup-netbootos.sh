#!/usr/bin/env bash
# Designed to be run on optiplexxx after build-netbootos.nix
set -euo pipefail

STORE_PATH=/exports/netboot/nix_store
SNAPSHOT=zroot/nix_store@netboot

systemctl stop nfs-server &
cp -v result/{bzImage,initrd,netboot.ipxe} /var/lib/tftproot/ &
cp -v result/registration /var/lib/wwwroot/ &

wait

if mountpoint $STORE_PATH; then umount $STORE_PATH; fi
zfs destroy $SNAPSHOT
zfs snapshot $SNAPSHOT
mount $STORE_PATH

systemctl start nfs-server

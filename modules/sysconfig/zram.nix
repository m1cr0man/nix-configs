{ config, lib, pkgs, ... }:
{
  systemd.services."zram@" = rec {
    description = "Automatically create and configure ZRAM devices based on a $DEVNUM-$SIZE generic argument";
    stopIfChanged = false;
    restartIfChanged = false;
    requires = [ "modprobe@zram.service" ];
    after = requires;
    unitConfig = {
      RequiresMountsFor = "/nix/store";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    environment.ZDEV = "%i";
    path = [ pkgs.e2fsprogs pkgs.util-linux ];
    script = ''
      set -x
      DEVNUM=''${ZDEV%-*}
      SIZE=''${ZDEV#*-}
      TARGET=/dev/zram$DEVNUM
      # If the newdevnum is >= the devnum we are looking for,
      # we can assume the device we want has been created.
      while [[ ! -e $TARGET && "$(cat /sys/class/zram-control/hot_add)" -lt $DEVNUM ]]; do
        sleep 0.1
      done
      sync
      zramctl -a zstd -s ''${SIZE}G $TARGET
      mke2fs -F -t ext4 -O ^has_journal $TARGET
    '';
    postStop = ''
      ( echo ''${ZDEV%-*} > /sys/class/zram-control/hot_remove ) || true
    '';
  };
}

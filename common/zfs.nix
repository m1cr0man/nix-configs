{ pkgs, config, ... }:
let
  serviceConfig = {
    after = [ "zfs.target" ];
    restartIfChanged = false;
    path = [ pkgs.zfsUnstable ];
    serviceConfig.Type = "oneshot";
  };
in {
  # Enable shell during boot for ZFS key prompt
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 6416;
      authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
      hostKeys = [
        /var/secrets/ssh_initrd_host_ed25519_key
      ];
    };
    postCommands = ''
      echo 'zfs load-key -a && killall zfs' >> /root/.profile
    '';
  };

  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 8;
    hourly = 0;
    daily = 7;
    weekly = 0;
    monthly = 1;
  };

  # Incremental scrubbing to avoid drive murder
  systemd.services.zfs-scrub = serviceConfig // {
    description = "Start ZFS incremental scrub";
    script = "zpool scrub $(zpool list -Ho name)";
  };

  systemd.services.zfs-scrub-stop = serviceConfig // {
    description = "Stop ZFS incremental scrub";
    script = "zpool scrub -p $(zpool list -Ho name) || true";
  };

  systemd.timers.zfs-scrub = {
    description = "Start ZFS incremental scrub";
    wantedBy = [ "timers.target" ];
    after = [ "zfs.target" ];
    timerConfig = {
      OnCalendar = config.m1cr0man.zfs.scrubStartTime;
      RandomizedDelaySec = 60;
      Persistent = false;
    };
  };

  # Runs 30 minutes after the above, or on next boot
  systemd.timers.zfs-scrub-stop = {
    description = "Stop ZFS incremental scrub";
    wantedBy = [ "timers.target" ];
    after = [ "zfs.target" ];
    timerConfig = {
      OnCalendar = config.m1cr0man.zfs.scrubStopTime;
      RandomizedDelaySec = 60;
      Persistent = true;
    };
  };
}

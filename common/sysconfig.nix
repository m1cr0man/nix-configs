{ pkgs, config, lib, ... }:
{
  imports = [
    ./base.nix
  ];

  # Enable shell during boot
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

  # Use DHCP during the initrd, then undo the config before stage 2 boot
  boot.initrd.postMountCommands = ''
    ip a flush eth0
    ip l set eth0 down
  '';

  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 8;
    hourly = 0;
    daily = 7;
    weekly = 0;
    monthly = 1;
  };

  # Fix vscode-server node binary on login
  environment.shellInit = let
    node = pkgs.nodejs-14_x;
    findutils = pkgs.findutils;
  in ''
    ${findutils}/bin/find ~/.vscode-server -type f -name node \( -execdir rm '{}' \; -and -execdir ln -s '${node}/bin/node' '{}' \; \)
  '';

  # Incremental scrubbing to avoid drive murder
  systemd.services.zfs-scrub = let
    stopCommand = ''
      zpool scrub -p $(zpool list -Ho name) || true
    '';
    scrubTime = builtins.toString (60 * 30);
  in {
    description = "Start ZFS incremental scrub";
    restartIfChanged = false;
    path = [ pkgs.zfsUnstable ];
    script = ''
      zpool scrub $(zpool list -Ho name)
      sleep ${scrubTime}
      ${stopCommand}
    '';
    preStop = stopCommand;
    serviceConfig.Type = "oneshot";
  };

  systemd.timers.zfs-scrub = {
    description = "Start ZFS incremental scrub";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = 60;
      Persistent = true;
    };
  };

  # Enable rsyslog
  services.rsyslogd.enable = true;
  services.rsyslogd.extraConfig = "*.* @127.0.0.1:6514;RSYSLOG_SyslogProtocol23Format";

  # Rotate logs with cron
  services.cron.enable = true;
  services.cron.systemCronJobs = [
    "0 4 * * * journalctl --vacuum-time=7d"
  ];
}

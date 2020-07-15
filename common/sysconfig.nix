{ pkgs, config, ... }:
{
  nixpkgs.config.allowUnfree = true;

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

  boot.kernelParams = [
    "boot.shell_on_fail"
    "ip=dhcp"
  ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    enableUnstable = true;
    forceImportRoot = true;
    forceImportAll = false;
  };
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 8;
    hourly = 0;
    daily = 7;
    weekly = 0;
    monthly = 1;
  };

  networking.domain = "m1cr0man.com";

  time.timeZone = "Europe/Dublin";
  i18n.defaultLocale = "en_IE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  environment.systemPackages = with pkgs; [
    wget vim git screen zstd git-crypt htop
  ];

  # Enable rsyslog
  services.rsyslogd.enable = true;
  services.rsyslogd.extraConfig = "*.* @127.0.0.1:6514;RSYSLOG_SyslogProtocol23Format";

  # Rotate logs with cron
  services.cron.enable = true;
  services.cron.systemCronJobs = [
    "0 4 * * * journalctl --vacuum-time=7d"
  ];

  # Enable accounting so systemd-cgtop can show IO load
  systemd.enableCgroupAccounting = true;
}

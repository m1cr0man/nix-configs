{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  # Enable shell during boot
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 6416;
      authorizedKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJWL3HA7WIxcJzP/G+l4VKr/G+zv8Cje7kzqlUzNenpG4ty62C4gaHnZfvQdzwYCnhYRHRZhx211Y3r0nw56s805TfRrr/rMguMabKqquqIlqq4pV1z5mhfLn6BJU+wa+OO3iLqMs6Wop5uIyBn6vjgkoE1xhXGe56bnynXn4p13lBXYhMvRuwRz5W2viZdD0YPXNEDAl5nJ5HglVgv+O2HTthgSLocwb3n7l/BWd7bpSFVge+/QiTxCeaHyrvJPiigAQASqQFUSvnIsOweFCumvcYjPUyYFFj/zXOuwqXd/tbaNc2wkqQ4jixaNwDHNrVcAQBSjHCdIM+11GMIYhPGWiEHn5i2ysWjFkMxuoAkJfQPKqqinnZf4BYJQd14CqEuvKntQI9lhnLG0N1SnyiRzLaG1APk8FHgfNdGXadnwpey9gWmdGRxFYB8MVhkY03bjNnEdw6b1CZeHCfak/SDy2P0mWMD+y66AWv7vIeu9BBpdmJ5nACTzptF276eF37v5m5FpbhvRvk5XAJYAyocBd+yaxWCDzPT7YPPoYUvIqngxur0x3XF8P21q47OPfqali8MRaT+qN1oPG0MBj5GflPKz+AkeP90k1DvGPQo7cBwPatfIlSmAynPwsMEVzfCNdjIOoU2TGTqDhwW7fHMuMen27mUAPpfJ+auZcPWw== lucas@oatfield"
      ];
    };
  };

  boot.kernelParams = [
    "boot.shell_on_fail"
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
    wget vim git screen steamcmd zstd
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

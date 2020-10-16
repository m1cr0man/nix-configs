{ pkgs, config, lib, ... }:
{
  imports = [
    ./options.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.kernelParams = [
    "boot.shell_on_fail"
  ];

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

  # Rotate logs with cron
  services.cron.enable = true;
  services.cron.systemCronJobs = [
    "0 4 * * * journalctl --vacuum-time=7d"
  ];

  # Enable accounting so systemd-cgtop can show IO load
  systemd.enableCgroupAccounting = true;
}

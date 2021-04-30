{ pkgs, config, lib, ... }:
{
  imports = [
    ./options.nix
  ];

  nixpkgs.config.allowUnfree = true;

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

  # Enable accounting so systemd-cgtop can show IO load
  systemd.enableCgroupAccounting = true;
}

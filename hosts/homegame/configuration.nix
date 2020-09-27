{ config, pkgs, ... }:
let
  secrets = import ../../common/secrets.nix;
in {

  imports =
    [
      ./hardware-configuration.nix
      ./vfio.nix
      ../../common/sysconfig.nix
      ../../services/ssh.nix
    ];

  system.stateVersion = "21.03";

  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" "video=efifb:off" ];
  boot.loader.efi = {
    efiSysMountPoint = "/boot";
    canTouchEfiVariables = true;
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  networking = {
    hostId = "e4a13b4c";
    hostName = "homegame";
    useDHCP = false;

    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.14.12";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.14.254";
    nameservers = [ "192.168.14.254" "1.1.1.1" ];
    wireless.enable = true;
  };

  users.users.lucas = {
    home = "/home/lucas";
    shell = pkgs.bashInteractive;
    group = "lucas";
    extraGroups = [ "wheel" ];
  };
  users.groups.lucas = {};

  # Enable KSM because the MC servers share a lot of data
  hardware.ksm.enable = true;
}

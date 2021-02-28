{ config, pkgs, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./samba-shares.nix
      ../../common/sysconfig.nix
      ../../services/ssh.nix
      ../../services/postgresql.nix
      ./postgresql.nix
    ];

  m1cr0man.chronograf.reverseProxy = false;

  system.stateVersion = "21.03";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.network.enable = lib.mkForce false;

  networking = {
    hostId = "4c1ff1d9";
    hostName = "chuck";
    useDHCP = false;

    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.137.2";
      prefixLength = 24;
    }];
    interfaces.eth1.ipv4.addresses = [{
      address = "192.168.14.1";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.14.254";
    nameservers = [ "192.168.14.254" "1.1.1.1" ];
  };
}

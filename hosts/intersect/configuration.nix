{ config, pkgs, ... }:
let
  secrets = import ../../common/secrets.nix;
in {

  imports =
    [
      ./hardware-configuration.nix
      ../../common/sysconfig.nix
      ../../services/ssh.nix
    ];

  system.stateVersion = "21.03";

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/disk/by-id/ata-TOSHIBA_THNS064GG2BNAA_40TS11UNT4LZ"];
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostId = "4cdf6f98";
    hostName = "intersect";
    useDHCP = false;

    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.14.1";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.14.254";
    nameservers = [ "192.168.14.254" "1.1.1.1" ];
  };
}

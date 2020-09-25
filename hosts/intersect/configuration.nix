{ config, pkgs, ... }:
let
  secrets = import ../../common/secrets.nix;

  mkUser = name: uid: {
      inherit name uid;
      home = "/zstorage/users/${name}";
      useDefaultShell = true;
      group = name;
      extraGroups = [ "users" "wheel" ];
  };
in {

  imports =
    [
      ./hardware-configuration.nix
      ../../common/sysconfig.nix
      ../../services/ssh.nix
      ../../services/samba.nix
    ];

  system.stateVersion = "21.03";

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/disk/by-id/ata-TOSHIBA_THNS064GG2BNAA_40TS11UNT4LZ" ];
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

  users.users = {
    lucas = mkUser "lucas" 1000;
    zeus = mkUser "zeus" 1001;
    adam = mkUser "adam" 1002;
    sophie = mkUser "sophie" 1003;
  };

  users.groups = {
    lucas.gid = 1000;
    zeus.gid = 1001;
    adam.gid = 1002;
    sophie.gid = 1003;
  };

  systemd.services.bootbeep = {
    description = "post-boot beep";
    wants = [ "network-online.target" ];
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      echo -e "\a" > /dev/console
      sleep 0.3
      echo -e "\a" > /dev/console
    '';
  };
}

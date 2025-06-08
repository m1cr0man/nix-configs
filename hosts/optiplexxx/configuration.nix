{ config, pkgs, lib, ... }:
let
  rootKeys = config.users.users.root.openssh.authorizedKeys.keys;
in {

  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "management/ssh"
    ]
    ++
    addModulesRecursive ./modules
    ++ [
      ./hardware-configuration.nix
    ];

  system.stateVersion = "25.11";
  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/disk/by-id/wwn-0x5000c5006cdc1295" ];
    configurationLimit = 5;
  };

  networking = {
    hostId = "462ba99b";
    hostName = "optiplexxx";
    useDHCP = false;

    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.14.2";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.14.254";
    nameservers = [ "192.168.14.254" "1.1.1.1" ];

    firewall.allowedTCPPorts = [ ];
    firewall.allowedUDPPorts = [ 27015 27016 27017 26900 26901 26902 26903 ];
  };

  # Enable KSM because the MC servers share a lot of data
  hardware.ksm.enable = true;
}

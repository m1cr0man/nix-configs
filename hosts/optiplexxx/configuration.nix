{ config, pkgs, ... }:
{

  imports =
    [
      ./hardware-configuration.nix
      ../../common/sysconfig.nix
      ../../services/ssh.nix
    ];

  system.stateVersion = "21.03";
  boot.loader.grub = {
    enable = true;
    version = 2;
    devices = [ "/dev/sda" ];
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
  };

  users.users.lucasguest = {
    isNormalUser = true;
    home = "/home/lucasguest";
    extraGroups = [ "wheel" ];
  };

  # Enable KSM because the MC servers share a lot of data
  hardware.ksm.enable = true;
}

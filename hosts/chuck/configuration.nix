{ config, pkgs, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./samba-shares.nix
      ../../common/sysconfig.nix
      ../../services/ssh.nix
      ../../services/postgresql.nix
      ../../services/tick
      ../../services/netbooter
      ../../services/grafana.nix
      ./postgresql.nix
    ];

  m1cr0man.chronograf.reverseProxy = false;
  m1cr0man.influxdb.bindAddress = "0.0.0.0";
  m1cr0man.netbooter.dhcpRange = "192.168.137.200,192.168.137.250";

  system.stateVersion = "21.03";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.network.enable = lib.mkForce false;

  # Reduce auto snapshot frequency
  services.zfs.autoSnapshot.frequent = lib.mkForce 0;

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

    firewall.allowedTCPPorts = [ 8086 8030 ];
  };
}

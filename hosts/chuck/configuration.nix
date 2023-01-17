{ config, pkgs, lib, ... }:
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "management/ssh"
      "monitoring"
      "servers/samba"
    ]
    ++
    addModulesRecursive ./modules
    ++ [
      ./hardware-configuration.nix
    ];

  m1cr0man = {
    influxdb.bindAddress = "0.0.0.0";
  };

  system.stateVersion = "22.11";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.network.enable = lib.mkForce false;

  # Reduce auto snapshot frequency
  services.zfs.autoSnapshot.frequent = lib.mkForce 0;

  # Need moar build ram
  services.logind.extraConfig = ''
    RuntimeDirectorySize=2G
  '';

  networking = {
    hostId = "4c1ff1d9";
    hostName = "chuck";
    useDHCP = false;
    useNetworkd = true;

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

  # Workaround for systemd-networkd-wait-online.service failures
  systemd.services."systemd-networkd-wait-online".serviceConfig.ExecStart = [
    ""
    "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any --timeout=30"
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGQ/+dK+9Y/QduSpNPoX/yfKYZazgUVwhs3DjH008U2C root@bgrs"
  ];
}

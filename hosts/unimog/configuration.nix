{ config, pkgs, lib, ... }:
let
  localSecrets = config.m1cr0man.secrets.unimog;
in
{

  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "management/ssh"
      "monitoring/client"
      "vms/gamesvm.nix"
      "www/tailscale.nix"
    ]
    ++
    addModulesRecursive ./modules
    ++ [
      ./hardware-configuration.nix
    ];

  system.stateVersion = "26.05";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.network.enable = lib.mkForce false;

  networking = {
    hostId = "68f9ddb5";
    useDHCP = false;
    useNetworkd = true;
    nftables.enable = true;

    usePredictableInterfaceNames = false;
    interfaces.eth0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = localSecrets.ipv4Address;
        prefixLength = localSecrets.ipv4Prefix;
      }];
      ipv6.addresses = [{
        address = localSecrets.ipv6Address;
        prefixLength = localSecrets.ipv6Prefix;
      }];
    };
    #defaultGateway = localSecrets.ipv4Gateway;
    #defaultGateway6.address = localSecrets.ipv6Gateway;

    nameservers = [ "185.12.64.1" "1.1.1.1" ];

    firewall.allowedUDPPorts = [ 64087 64100 ];
  };

  # Required for ZFS unlocking
  boot.initrd.systemd = {
    network = {
      enable = true;
      networks."20-eth0" = {
        enable = true;
        name = "eth0";
        DHCP = "no";
        address = [
          "${localSecrets.ipv4Address}/${toString localSecrets.ipv4Prefix}"
          "${localSecrets.ipv6Address}/${toString localSecrets.ipv6Prefix}"
        ];
        routes = [{Gateway = localSecrets.ipv4Gateway;}];
      };
    };
  };

  # Workaround for https://github.com/NixOS/nixpkgs/issues/178078
  systemd.network.networks."40-eth0".gateway = [ localSecrets.ipv4Gateway localSecrets.ipv6Gateway ];

  # Workaround for systemd-networkd-wait-online.service failures
  systemd.services."systemd-networkd-wait-online".serviceConfig.ExecStart = [
    ""
    "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any --timeout=30"
  ];

  m1cr0man = {
    monitoring.hostMetrics = true;
    zfs = {
      scrubStartTime = "*-*-* 07:00:00";
      scrubStopTime = "*-*-* 07:15:00";
      encryptedDatasets = [ "zunimog_ssd" "zunimog_hdd" ];
    };
    # Fix for routing issues
    tailscale.enableLocalRoutingPatch = true;
  };

  # Enable KSM because the MC servers share a lot of data
  hardware.ksm.enable = true;

  # Enable powersave governor because this server is mental anyway
  powerManagement.cpuFreqGovernor = "powersave";
  hardware.cpu.intel.updateMicrocode = true;
}

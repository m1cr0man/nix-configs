{ config, pkgs, lib, ... }:
let
  localSecrets = builtins.extraBuiltins.readSops ./secrets.nix.enc;
in
{

  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "management/ssh"
      "vms/gamesvm.nix"
    ]
    ++
    addModulesRecursive ./modules
    ++ [
      ./hardware-configuration.nix
    ];

  system.stateVersion = "22.05";

  boot.loader.grub = {
    enable = true;
    version = 2;
    devices = [ "/dev/disk/by-id/wwn-0x5002538c402dc7cc" ];
    configurationLimit = 5;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.loader.efi.efiSysMountPoint = "/boot";

  # Set network configuration for initrd
  boot.kernelParams = [
    "ip=${localSecrets.ipv4Address}::${localSecrets.ipv4Gateway}:${localSecrets.ipv4Netmask}:${config.networking.hostName}:eth0:static"
  ];

  networking = {
    hostId = "68f9ddb5";
    useDHCP = false;
    useNetworkd = true;

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

    firewall.allowedTCPPorts = [
      # Mail ports
      25
      143
      587
      4190
    ];
    firewall.allowedUDPPorts = [
      # Space Engineers
      27016
      # Valheim
      2456
      2457
      2458
    ];
  };

  # Workaround for https://github.com/NixOS/nixpkgs/issues/178078
  systemd.network.networks."40-eth0".gateway = [ localSecrets.ipv4Gateway localSecrets.ipv6Gateway ];

  # Workaround for systemd-networkd-wait-online.service failures
  systemd.services."systemd-networkd-wait-online".serviceConfig.ExecStart = [
    ""
    "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any --timeout=30"
  ];

  m1cr0man = {
    general.rsyslogServer = "127.0.0.1:6514";
    zfs = {
      scrubStartTime = "*-*-* 07:00:00";
      scrubStopTime = "*-*-* 07:15:00";
      encryptedDatasets = [ "zunimog_ssd" "zunimog_hdd" ];
    };
  };

  # Enable KSM because the MC servers share a lot of data
  hardware.ksm.enable = true;

  # Enable powersave governor because this server is mental anyway
  powerManagement.cpuFreqGovernor = "powersave";
  hardware.cpu.intel.updateMicrocode = true;

}

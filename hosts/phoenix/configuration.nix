{ config, pkgs, lib, ... }:
let
  localSecrets = builtins.extraBuiltins.readSops ./secrets.nix.enc;
  prodACMEServer = "https://acme-v02.api.letsencrypt.org/directory";
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "management/ssh"
      "www/bind.nix"
      "www/imhumane-rs.nix"
      "www/mailform-rs.nix"
      "gaming/minecraft"
    ]
    ++
    addModulesRecursive ./modules
    ++ [
      ./hardware-configuration.nix
    ];

  system.stateVersion = "23.11";

  boot.loader.grub = {
    enable = true;
    configurationLimit = 5;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      {
        devices = [
          "/dev/disk/by-id/wwn-0x5002538c0004258a"
        ];
        path = "/boot";
      }
      {
        devices = [
          "/dev/disk/by-id/wwn-0x50025388003531bd"
        ];
        path = "/boot2";
      }
    ];
  };

  # Reduce auto snapshot frequency
  services.zfs.autoSnapshot.frequent = lib.mkForce 0;

  # Set network configuration for initrd
  boot.kernelParams = [
    "ip=${localSecrets.ipv4Address}::${localSecrets.ipv4Gateway}:${localSecrets.ipv4Netmask}:${config.networking.hostName}:eth0:static"
  ];

  networking = {
    hostId = "19b5c3da";
    domain = lib.mkForce "vccomputers.ie";
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
    defaultGateway = {
      address = localSecrets.ipv4Gateway;
      interface = "eth0";
    };
    defaultGateway6 = {
      address = localSecrets.ipv6Gateway;
      interface = "eth0";
    };

    nameservers = [ "185.12.64.1" "1.1.1.1" ];

    firewall.allowedTCPPorts = [ 80 443 ];
  };

  # Workaround for systemd-networkd-wait-online.service failures
  systemd.services."systemd-networkd-wait-online".serviceConfig.ExecStart = [
    ""
    "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any --timeout=30"
  ];

  # Enable VSCode Remote Server
  services.vscode-server.enable = true;

  m1cr0man = {
    zfs = {
      scrubStartTime = "*-*-* 05:00:00";
      scrubStopTime = "*-*-* 05:15:00";
      encryptedDatasets = [ "zphoenix_ssd" ];
    };
  };

  # Enable KSM because the MC servers share a lot of data
  hardware.ksm.enable = true;
}

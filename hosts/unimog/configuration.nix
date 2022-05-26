{ config, pkgs, lib, ... }:
let
  localSecrets = builtins.extraBuiltins.readSops ./secrets.nix.enc;
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

  system.stateVersion = "22.05";

  boot.loader.grub = {
    enable = true;
    version = 2;
    devices = [ "/dev/sdc" ];
    configurationLimit = 5;
  };

  networking = {
    hostId = "68f9ddb5";
    # Required for initrd DHCP
    useDHCP = true;

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
    defaultGateway = localSecrets.ipv4Gateway;
    defaultGateway6 = {
      address = localSecrets.ipv6Gateway;
      interface = "eth0";
    };
    nameservers = [ "185.12.64.1" "1.1.1.1" ];

    firewall.allowedTCPPorts = [ ];
    firewall.allowedUDPPorts = [ ];
  };

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
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

}

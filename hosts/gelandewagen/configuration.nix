{ config, lib, pkgs, myModulesPath, addModules, addModulesRecursive, ... }:
{

  imports =
    (
      addModules myModulesPath [
        "sysconfig"
        "gaming/minecraft"
        "gaming/openttd.nix"
        "monitoring"
        "servers/postgresql.nix"
        "servers/vault.nix"
        "management/ssh"
        "www/acme.nix"
        "www/bind.nix"
        "www/httpd.nix"
        "www/matrix.nix"
        "www/minio.nix"
        "www/plex.nix"
        "www/weechat.nix"
      ]
    ) ++ (
      addModulesRecursive ./modules
    ) ++ [
      ./hardware-configuration.nix
    ];

  system.stateVersion = "21.03";
  boot.loader.grub = {
    enable = true;
    version = 2;
    devices = [ "/dev/sda" "/dev/sdb" ];
    configurationLimit = 5;
  };
  nix.trustedUsers = [ "root" "lucas" ];

  m1cr0man = {
    general.rsyslogServer = "127.0.0.1:6514";
    zfs = {
      scrubStartTime = "*-*-* 07:00:00";
      scrubStopTime = "*-*-* 07:15:00";
      encryptedDatasets = [ "zgelandewagen" ];
    };
  };

  # Used for some MC servers
  # numDevices = Number of MC servers using ramdisk
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    swapDevices = 0;
    numDevices = 2;
    memoryPercent = 12;
    memoryMax = 3072000000000;
  };

  networking = {
    hostId = "4cdf6f98";
    hostName = "gelandewagen";
    useDHCP = false;
    # hosts."127.0.0.1" = [ "m1cr0man.com" ];

    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "144.76.44.123";
      prefixLength = 27;
    }];
    interfaces.eth0.ipv6.addresses = [{
      address = "2a01:4f8:191:503f::1";
      prefixLength = 64;
    }];
    defaultGateway = "144.76.44.97";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    nameservers = [ "213.133.98.98" "1.1.1.1" ];
    hosts."136.206.15.3" = [ "irc.redbrick.dcu.ie" ];
  };

  systemd.services.stress = {
    description = "CPU stress to stop crashes";
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.stress}/bin/stress --cpu 2
    '';
    serviceConfig = {
      Restart = "always";
      CPUWeight = 5;
      CPUSchedulingPriority = 2;
    };
  };

  networking.firewall.allowedTCPPorts = [ 27015 27016 26900 1802 7776 7777 ];
  networking.firewall.allowedUDPPorts = [ 26900 26901 26902 27005 27015 27016 27020 7776 7777 ];
}

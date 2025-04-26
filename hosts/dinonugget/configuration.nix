{ pkgs, lib, modulesPath, ... }: {
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "management/ssh"
      "www/tailscale.nix"
    ]
    ++
    addModulesRecursive ./modules
    ++ [
      ./hardware-configuration.nix
    ];

  system.stateVersion = "25.05";

  networking = {
    hostId = "ff90ce60";
    useDHCP = false;
    useNetworkd = true;
    nftables.enable = true;
    firewall.trustedInterfaces = [ "tailscale0" ];

    usePredictableInterfaceNames = false;
    interfaces.eth0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.137.10";
        prefixLength = 24;
      }];
    };
    interfaces.wlan0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.2.10";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.2.254";
      interface = "wlan0";
    };

    wireless = {
      enable = true;
      allowAuxiliaryImperativeNetworks = true;
      userControlled.enable = true;
    };

    nameservers = [ "192.168.2.254" "1.1.1.1" ];
  };

  systemd.network.networks."40-eth0" = {
    linkConfig.RequiredForOnline = "no";
  };
  systemd.network.networks."40-wlan0" = {
    linkConfig.RequiredForOnline = "routable";
    networkConfig.IgnoreCarrierLoss = "3s";
  };

  # Required for building aarch64-linux packages
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Increase nix working directory space
  services.logind.extraConfig = ''
    RuntimeDirectorySize=2G
  '';

  # Reduce auto snapshot frequency
  services.zfs.autoSnapshot.frequent = lib.mkForce 0;

  # Fix for routing issues
  m1cr0man.tailscale.enableLocalRoutingPatch = true;
}

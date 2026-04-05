{ pkgs, lib, modulesPath, ... }: {
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "3dprinting/server.nix"
      "management/ssh"
      "www/tailscale.nix"
    ]
    ++
    addModulesRecursive ./modules
    ++ [
      ./hardware-configuration.nix
    ];

  system.stateVersion = "25.11";

  networking = {
    hostId = "4f919b2d";
    useDHCP = false;
    useNetworkd = true;
    nftables.enable = true;
    wireless.enable = true;
    wireless.allowAuxiliaryImperativeNetworks = true;

    usePredictableInterfaceNames = false;
    interfaces.eth0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.254.5";
        prefixLength = 24;
      }];
    };
    interfaces.wlan0 = {
      ipv4.addresses = [{
        address = "192.168.2.5";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.2.254";
      interface = "wlan0";
    };

    nameservers = [ "1.1.1.1" "192.168.2.254" ];

    # Enable LLMNR
    firewall.allowedUDPPorts = [ 5355 ];
  };

  # Fix for routing issues
  m1cr0man.tailscale.enableLocalRoutingPatch = true;
}

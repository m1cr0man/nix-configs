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
    useDHCP = false;
    useNetworkd = true;
    nftables.enable = true;

    usePredictableInterfaceNames = false;
    interfaces.eth0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.14.8";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.14.254";
      interface = "eth0";
    };

    nameservers = [ "192.168.14.254" "1.1.1.1" ];

    # Enable LLMNR
    firewall.allowedUDPPorts = [ 5355 ];
  };

  # Fix for routing issues
  m1cr0man.tailscale.enableLocalRoutingPatch = true;

  # Disable ZFS
  m1cr0man.zfs.enable = false;
  boot.supportedFilesystems.zfs = lib.mkForce false;

  environment.systemPackages = [
    # For printer firmware flashing
    pkgs.dfu-util
  ];
}

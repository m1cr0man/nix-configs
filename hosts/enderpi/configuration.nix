{ pkgs, lib, modulesPath, ... }: {
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "3dprinting/server.nix"
      "3dprinting/rpicam.nix"
      "rpi/bootloader"
      "rpi/hardware-rpi3.nix"
      "management/ssh"
      "www/tailscale.nix"
    ]
    ++
    addModulesRecursive ./modules;

  system.stateVersion = "25.05";

  # Fix from https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1350599022
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  networking = {
    useDHCP = false;
    useNetworkd = true;
    nftables.enable = true;
    wireless.enable = true;
    wireless.allowAuxiliaryImperativeNetworks = true;

    usePredictableInterfaceNames = false;
    interfaces.eth0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.137.22";
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

    nameservers = [ "192.168.2.254" "1.1.1.1" ];
  };

  # Fix for routing issues
  m1cr0man.tailscale.enableLocalRoutingPatch = true;

  # Disable ZFS
  m1cr0man.zfs.enable = false;
  boot.supportedFilesystems.zfs = lib.mkForce false;

  # Enable the watchdog
  systemd.watchdog.runtimeTime = "14s";

  environment.systemPackages = [
    pkgs.libraspberrypi
  ];
}

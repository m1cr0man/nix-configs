{ pkgs, lib, modulesPath, ... }: {
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "management/ssh"
      "www/tailscale.nix"
    ]
    ++
    addModulesRecursive ./modules
    ++
    # Modules from Dinonugget
    addModules ../dinonugget/modules [
      "desktop.nix"
      "flatpak.nix"
      "gaming.nix"
      "preservation.nix"
    ]
    ++ [
      ./hardware-configuration.nix
    ];

  system.stateVersion = "26.05";

  networking = {
    hostId = "d339c331";
    usePredictableInterfaceNames = false;
    nftables.enable = true;
    wireless = {
      enable = true;
      allowAuxiliaryImperativeNetworks = true;
      userControlled = true;
      scanOnLowSignal = false;
    };
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
  };
  preservation.preserveAt."/nix/persist".directories = [
    "/etc/NetworkManager/system-connections"
  ];

  # Fix for routing issues
  m1cr0man.tailscale.enableLocalRoutingPatch = true;

  # Thunderbolt
  environment.systemPackages = [
    pkgs.kdePackages.plasma-thunderbolt
  ];
  services.hardware.bolt.enable = true;
}

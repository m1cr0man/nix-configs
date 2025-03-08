{ pkgs, lib, modulesPath, ... }: let
  # Change this to true when building the boot image
  # AKA config.system.build.sdImage
  bootImage = false;
in {
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "management/ssh"
      "www/tailscale.nix"
    ]
    ++
    addModulesRecursive ./modules
    ++ [
      ./hardware-configuration.nix
      # "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel.nix"
    ]
    ++ (lib.optionals (bootImage) [
      "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"
      {
        # bzip2 compression takes loads of time with emulation, skip it. Enable this if you're low
        # on space.
        # Thanks to https://github.com/Chris2011/nixos-docker-image-builder/blob/a73dc36eee4718770789d8ba1142350e40b63c2d/config/sd-image.nix#L17
        sdImage.compressImage = false;

      }
    ]);

  system.stateVersion = "24.11";

  nix.settings.trusted-users = [ "root" ];

  # Fix from https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1350599022
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  networking.wireless.enable = true;
  networking.wireless.allowAuxiliaryImperativeNetworks = true;

  networking = {
    useDHCP = false;
    useNetworkd = true;
    nftables.enable = true;

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

  # OpenSSH is forced to have an empty `wantedBy` on the installer system[1], this won't allow it
  # to be automatically started. Override it with the normal value.
  # [1] https://github.com/NixOS/nixpkgs/blob/9e5aa25/nixos/modules/profiles/installation-device.nix#L76
  systemd.services.sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
  services.sshd.enable = true;

  # Disable ZFS
  m1cr0man.zfs.enable = false;

  environment.systemPackages = [
    pkgs.libraspberrypi
  ];
}

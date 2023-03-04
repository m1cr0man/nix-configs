{ lib, ... }:
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "management/ssh"
    ]
    ++
    addModulesRecursive ./modules
    ++ [
      ./hardware-configuration.nix
    ];

  system.stateVersion = "23.05";

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    grub.enable = false;
    systemd-boot.enable = true;
    efi.efiSysMountPoint = "/boot";
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostId = "2c652136";
    firewall.enable = false;
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
    llmnr = "true";
    extraConfig = ''
      MulticastDNS=true
    '';
    fallbackDns = [ "1.1.1.1" ];
  };
  networking.networkmanager = {
    dns = "systemd-resolved";
    connectionConfig = {
      "connection.mdns" = 2;
      "connection.llmnr" = 2;
    };
  };

  m1cr0man = {
    zfs = {
      scrubStartTime = "*-*-* 07:00:00";
      scrubStopTime = "*-*-* 07:15:00";
      arcMaxGb = 1;
    };
  };
}

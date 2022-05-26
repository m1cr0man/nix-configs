{ config, lib, pkgs, ... }:
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "management/ssh"
    ];

  system.stateVersion = "22.05";
  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "usb_storage" "sd_mod" "e1000e" ];
  boot.kernelModules = [ "kvm-intel" "zram" "e1000e" ];

  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  nix.settings.max-jobs = lib.mkDefault 8;
}

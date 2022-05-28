{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Note e1000e for networking during boot
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "sd_mod" "usb_storage" "e1000e" ];
  boot.kernelModules = [ "kvm-intel" "zram" ];

  fileSystems."/" =
    { device = "zunimog_ssd/nixos/root";
      fsType = "zfs";
    };

  fileSystems."/nix/store" =
    { device = "zunimog_ssd/nixos/store";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "zunimog_hdd/nixos/home";
      fsType = "zfs";
    };

  fileSystems."/var" =
    { device = "zunimog_hdd/nixos/var";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/9CA6-9CCC";
      fsType = "vfat";
    };

  swapDevices = [
    { device = "/dev/disk/by-uuid/828d45ec-9ec4-4f0e-8b5f-1b8ceed8e5c8"; }
  ];
}

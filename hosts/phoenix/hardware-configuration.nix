{ config, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  nixpkgs.hostPlatform = "x86_64-linux";
  powerManagement.cpuFreqGovernor = "powersave";
  hardware.cpu.intel.updateMicrocode = true;

  # Note e1000e for networking during boot
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "sd_mod" "usb_storage" "e1000e" ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" =
    { device = "zphoenix_ssd/nixos/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zphoenix_ssd/nixos/nix";
      fsType = "zfs";
    };

  fileSystems."/var" =
    { device = "zphoenix_ssd/nixos/var";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "zphoenix_ssd/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-partlabel/ESP_SDA";
      fsType = "vfat";
      options = [ "nofail" ];
    };

  fileSystems."/boot2" =
    { device = "/dev/disk/by-partlabel/ESP_SDB";
      fsType = "vfat";
      options = [ "nofail" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-partlabel/SWAP_SDA"; }
      { device = "/dev/disk/by-partlabel/SWAP_SDB"; }
    ];
}

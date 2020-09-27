{ lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "xhci_hcd" "ehci_pci" "ahci" "usbhid" "usb_storage" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Fixes buggy loading of the Renesas USB3 controller
  boot.initrd.preDeviceCommands = ''
      rmmod xhci_pci
      rmmod xhci_hcd
      echo 1 > '/sys/bus/pci/devices/0000:02:00.0/reset'
      modprobe xhci_hcd
      modprobe xhci_pci
    '';
  };

  fileSystems."/" =
    { device = "zroot/nixos";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zroot/nix_store";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6CA2-5835";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-partuuid/aea0578e-f42c-4dfa-b84b-4031eb17aeab"; priority = 10; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}

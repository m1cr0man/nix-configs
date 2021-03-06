# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "usb_storage" "uas" "usbhid" "floppy" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

  fileSystems."/" =
    { device = "zroot/nixos";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zroot/nix_store";
      fsType = "zfs";
    };

  swapDevices =[
    { device = "/dev/disk/by-partuuid/adc0f5a6-ff72-4bae-8b7f-f20702e3846a"; }
  ];
}

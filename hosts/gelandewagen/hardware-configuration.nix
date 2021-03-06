# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

let
  mountConfig = name: {
    device = "zgelandewagen/${name}";
    fsType = "zfs";
    options = [ "nofail" ];
  };
in {
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "usb_storage" "sd_mod" "r8169" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "intel_idle.max_cstate=0" "processor.max_cstate=1" ];

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/64BB-47FC";
      fsType = "vfat";
    };

  fileSystems."/" =
    { device = "zgelandewagen/nixos";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zgelandewagen/nixos/store";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "zgelandewagen/home";
      fsType = "zfs";
    };

  fileSystems."/var/gaming" = mountConfig "gaming";

  fileSystems."/var/gaming/minecraft" = mountConfig "gaming/minecraft";

  fileSystems."/var/lib/docker" = mountConfig "services/docker";

  fileSystems."/var/www/m1cr0blog" = mountConfig "services/m1cr0blog";

  fileSystems."/var/www/minio" = mountConfig "services/minio";

  fileSystems."/var/www/nextcloud" = mountConfig "services/nextcloud";

  fileSystems."/var/lib/tick" = mountConfig "services/tick";

  fileSystems."/var/lib/plex" = mountConfig "services/plex";

  fileSystems."/var/lib/vault" = mountConfig "services/vault";

  swapDevices = [
    { device = "/dev/disk/by-partuuid/6120e0b2-ded9-4641-bb93-d0be45c72d57"; priority = 100; }
  ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  # Enable KSM because the MC servers share a lot of data
  hardware.ksm.enable = true;
}

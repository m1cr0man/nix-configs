{ config, lib, pkgs, modulesPath, ... }:
let
  mountConfig = name: {
    device = "zgelandewagen/${name}";
    fsType = "zfs";
    options = [ "nofail" ];
  };
in
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Note r8169 for networking during boot
  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "usb_storage" "sd_mod" "r8169" ];
  boot.kernelModules = [ "kvm-intel" "zram" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "intel_idle.max_cstate=0" "processor.max_cstate=1" ];

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/64BB-47FC";
      fsType = "vfat";
    };

  fileSystems."/" =
    {
      device = "zgelandewagen/nixos";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    {
      device = "zgelandewagen/nixos/store";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "zgelandewagen/home";
      fsType = "zfs";
    };

  fileSystems."/opt/vms" = mountConfig "vms";

  fileSystems."/var/gaming" = mountConfig "gaming";

  fileSystems."/var/gaming/minecraft" = mountConfig "gaming/minecraft";

  fileSystems."${builtins.head config.services.minio.dataDir}" = mountConfig "services/minio";

  fileSystems."/var/www/nextcloud" = mountConfig "services/nextcloud";

  fileSystems."/var/lib/tick" = mountConfig "services/tick";

  fileSystems."${config.services.plex.dataDir}" = mountConfig "services/plex";

  fileSystems."${config.services.vault.storagePath}" = mountConfig "services/vault";

  swapDevices = [
    { device = "/dev/disk/by-partuuid/6120e0b2-ded9-4641-bb93-d0be45c72d57"; priority = 100; }
  ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  # Enable KSM because the MC servers share a lot of data
  hardware.ksm.enable = true;
}

{ lib, pkgs, ... }: {
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.network.enable = lib.mkForce false;
  # Required for preservation anyway
  boot.initrd.systemd.enable = true;

  # Newer kernel
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  # Kernel modules
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ "nvme" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Huge pages
  boot.kernelParams = [ "hugepagesz=2M" "hugepages=512" ];

  # Firmware is required in stage-1 for early KMS.
  hardware.enableRedistributableFirmware = true;

  # Firmware updates
  hardware.cpu.intel.updateMicrocode = true;

  # Filesystems
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "noatime" "size=256M" "mode=755" ];
    };
    "/boot" = {
      device = "/dev/disk/by-partlabel/ESP";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
    "/nix" = {
      device = "/dev/disk/by-partlabel/NIXOS";
      fsType = "f2fs";
    };
    # Separate /tmp mount to prevent root storage space being used up
    "/tmp" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=2048M" "mode=777" ];
    };
    "/var/tmp" = {
      depends = [ "/tmp" ];
      device = "/tmp";
      fsType = "none";
      options = [ "bind" ];
    };
  };
}

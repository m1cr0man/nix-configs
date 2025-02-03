{ pkgs, lib, ... }:
{
  nixpkgs.hostPlatform.system = "aarch64-linux";
  # nixpkgs.crossSystem.system = "aarch64-linux";
  nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_rpi3;
  boot.consoleLogLevel = lib.mkDefault 7;

  hardware.enableRedistributableFirmware = true;

  # Helps with memory usage - we only have 1gb
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    swapDevices = 1;
    memoryPercent = 20;
    memoryMax = 256000000;
    priority = 100;
  };

  swapDevices = [{
    device = "/swapfile";
    size = 1024;
    priority = 10;
    discardPolicy = "once";
    options = [ "nofail" ];
  }];

  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "vfat";
      # Alternatively, this could be removed from the configuration.
      # The filesystem is not needed at runtime, it could be treated
      # as an opaque blob instead of a discrete FAT32 filesystem.
      options = [ "nofail" "noauto" ];
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
}

{ pkgs, lib, ... }:
{
  # The hardware configuration on all my RPis is identical.

  nixpkgs.hostPlatform.system = "aarch64-linux";
  # nixpkgs.crossSystem.system = "aarch64-linux";
  nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.

  hardware.enableRedistributableFirmware = true;

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi3;
    consoleLogLevel = 7;
    # Required for preservation anyway
    initrd.systemd.enable = true;

    loader.rpi.enable = true;
    loader.rpi.stripRpi4 = true;
  };

  # Helps with memory usage - we only have 1gb
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    swapDevices = 1;
    memoryPercent = 20;
    memoryMax = 256000000;
  };

  # There's no point having an on-disk swap file because the sdcard is so slow.

  fileSystems = {
    "/" = lib.mkForce {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=32M" "mode=755" ];
    };
    # Separate /tmp mount to prevent root storage space being used up
    "/tmp" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=32M" "mode=777" ];
    };
    "/var/tmp" = {
      depends = [ "/tmp" ];
      device = "/tmp";
      fsType = "none";
      options = [ "bind" ];
    };
    "/nix" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    "/boot" = {
      depends = [ "/nix" ];
      device = "/nix/boot";
      fsType = "none";
      options = [ "bind" ];
    };
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      # Alternatively, this could be removed from the configuration.
      # The filesystem is not needed at runtime, it could be treated
      # as an opaque blob instead of a discrete FAT32 filesystem.
      options = [ "nofail" ];
    };
  };
}

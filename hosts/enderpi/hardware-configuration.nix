{ pkgs, lib, ... }:
{
  nixpkgs.hostPlatform.system = "aarch64-linux";
  # nixpkgs.crossSystem.system = "aarch64-linux";
  nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.

  # boot.loader.grub.enable = false;
  boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_rpi3;
  # boot.consoleLogLevel = lib.mkDefault 7;
  # Required for preservation anyway
  boot.initrd.systemd.enable = true;

  # hardware.enableRedistributableFirmware = true;

  raspberry-pi-nix.uboot.enable = true;
  raspberry-pi-nix.libcamera-overlay.enable = false;
  hardware.raspberry-pi.config.all = {
    options = {
      # The firmware will start our u-boot binary rather than a
      # linux kernel.
      kernel = {
        enable = true;
        value = "u-boot-rpi-arm64.bin";
      };
      arm_64bit = {
        enable = true;
        value = true;
      };
      enable_uart = {
        enable = true;
        value = true;
      };
      avoid_warnings = {
        enable = true;
        value = true;
      };
      camera_auto_detect = {
        enable = true;
        value = true;
      };
      display_auto_detect = {
        enable = true;
        value = true;
      };
      disable_overscan = {
        enable = true;
        value = true;
      };
    };
    base-dt-params = {
      krnbt = {
        enable = true;
        value = "on";
      };
      spi = {
        enable = true;
        value = "on";
      };
    };
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

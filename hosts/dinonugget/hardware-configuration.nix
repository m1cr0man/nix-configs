{ lib, pkgs, ... }: {
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.network.enable = lib.mkForce false;
  # Required for preservation anyway
  boot.initrd.systemd.enable = true;

  # Newer kernel
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  # Kernel modules
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" "nvme" ];
  boot.kernelModules = [ "kvm-amd" ];

  # Huge pages
  boot.kernelParams = [ "hugepagesz=2M" "hugepages=512" ];

  # Firmware is required in stage-1 for early KMS.
  hardware.enableRedistributableFirmware = true;

  # Firmware updates
  hardware.cpu.amd.updateMicrocode = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

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
      device = "zdinonugget/nixos/nix";
      fsType = "zfs";
    };
    "/home" = {
      device = "zdinonugget/home";
      fsType = "zfs";
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

  swapDevices = [{
    device = "/dev/disk/by-partlabel/SWAP";
  }];

  # Optimizations from nix-gaming
  boot.kernel.sysctl = {
    # 20-shed.conf
    "kernel.sched_cfs_bandwidth_slice_us" = 3000;
    # 20-net-timeout.conf
    # This is required due to some games being unable to reuse their TCP ports
    # if they're killed and restarted quickly - the default timeout is too large.
    "net.ipv4.tcp_fin_timeout" = 5;
    # 30-splitlock.conf
    # Prevents intentional slowdowns in case games experience split locks
    # This is valid for kernels v6.0+
    "kernel.split_lock_mitigate" = 0;
    # 30-vm.conf
    # USE MAX_INT - MAPCOUNT_ELF_CORE_MARGIN.
    # see comment in include/linux/mm.h in the kernel tree.
    "vm.max_map_count" = 2147483642;
  };
}

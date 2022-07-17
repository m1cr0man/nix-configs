{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Note e1000e for networking during boot
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "sd_mod" "usb_storage" "e1000e" ];
  boot.kernelModules = [ "kvm-intel" "zram" ];

  fileSystems."/" =
    {
      device = "zunimog_ssd/nixos/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    {
      device = "zunimog_ssd/nixos/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "zunimog_hdd/nixos/home";
      fsType = "zfs";
    };

  fileSystems."/var" =
    {
      device = "zunimog_hdd/nixos/var";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-partlabel/ESP";
      fsType = "vfat";
    };

  fileSystems."/home/lucas/ssd" =
    {
      device = "zunimog_ssd/lucas";
      fsType = "zfs";
    };

  fileSystems."/home/zeus/ssd" =
    {
      device = "zunimog_ssd/zeus";
      fsType = "zfs";
    };

  fileSystems."/var/lib/vms" =
    {
      device = "zunimog_hdd/vms";
      fsType = "zfs";
    };

  fileSystems."/var/lib/vms/ssd" =
    {
      device = "zunimog_ssd/vms";
      fsType = "zfs";
    };

  fileSystems."/var/lib/containers/database" =
    {
      device = "zunimog_hdd/containers/database";
      fsType = "zfs";
    };

  fileSystems."/var/lib/containers/email" =
    {
      device = "zunimog_hdd/containers/email";
      fsType = "zfs";
    };

  fileSystems."/var/lib/containers/web" =
    {
      device = "zunimog_hdd/containers/web";
      fsType = "zfs";
    };

  fileSystems."/var/lib/containers/gaming" =
    {
      device = "zunimog_hdd/containers/gaming";
      fsType = "zfs";
    };

  fileSystems."/var/lib/containers/gaming/zram0" =
    {
      device = "/dev/zram0";
      fsType = "ext4";
      options = [
        "nofail"
        "x-systemd.requires=zram@0-5.service"
      ];
    };

  fileSystems."/var/lib/containers/gaming/zram1" =
    {
      device = "/dev/zram1";
      fsType = "ext4";
      options = [
        "nofail"
        "x-systemd.requires=zram@1-5.service"
      ];
    };

  swapDevices = [
    { device = "/dev/disk/by-partlabel/Swap"; }
  ];
}

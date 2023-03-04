{ modulesPath, ... }:
{
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
  boot.kernelModules = [ "zram" "kvm-amd" ];

  fileSystems."/" =
    {
      device = "zroot/nixos/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    {
      device = "zroot/nixos/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "zroot/home";
      fsType = "zfs";
    };

  fileSystems."/var" =
    {
      device = "zroot/nixos/var";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-partlabel/ESP";
      fsType = "vfat";
    };

  swapDevices = [
    { device = "/dev/disk/by-partlabel/Swap"; }
  ];
}

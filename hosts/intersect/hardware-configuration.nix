{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "firewire_ohci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" "pcspkr" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/5727b3e2-2669-4a24-8dc8-07839fd874e2";
      fsType = "f2fs";
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/09536620-4b5c-48dc-8280-4bf35f1d46f2";
      fsType = "f2fs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6C45-BA1F";
      fsType = "vfat";
    };

  fileSystems."/zgaming/origin" =
    { device = "zgaming/origin";
      fsType = "zfs";
    };

  fileSystems."/zgaming/origin/master" =
    { device = "zgaming/origin/master";
      fsType = "zfs";
    };

  fileSystems."/zgaming/steam" =
    { device = "zgaming/steam";
      fsType = "zfs";
    };

  fileSystems."/zgaming/steam/adam" =
    { device = "zgaming/steam/adam";
      fsType = "zfs";
      options = [ "nofail" ];
    };

  fileSystems."/zgaming/steam/lucas" =
    { device = "zgaming/steam/lucas";
      fsType = "zfs";
      options = [ "nofail" ];
    };

  fileSystems."/zgaming/steam/master" =
    { device = "zgaming/steam/master";
      fsType = "zfs";
    };

  fileSystems."/zstorage/apps_drivers" =
    { device = "zstorage/apps_drivers";
      fsType = "zfs";
    };

  fileSystems."/zstorage/games_stuff" =
    { device = "zstorage/games_stuff";
      fsType = "zfs";
    };

  fileSystems."/zstorage/movies" =
    { device = "zstorage/movies";
      fsType = "zfs";
    };

  fileSystems."/zstorage/music" =
    { device = "zstorage/music";
      fsType = "zfs";
    };

  fileSystems."/zstorage/pc_backups" =
    { device = "zstorage/pc_backups";
      fsType = "zfs";
    };

  fileSystems."/zstorage/pictures_videos" =
    { device = "zstorage/pictures_videos";
      fsType = "zfs";
    };

  fileSystems."/zstorage/plex" =
    { device = "zstorage/plex";
      fsType = "zfs";
    };

  fileSystems."/zstorage/plex/config" =
    { device = "zstorage/plex/config";
      fsType = "zfs";
    };

  fileSystems."/zstorage/plex/transcode" =
    { device = "zstorage/plex/transcode";
      fsType = "zfs";
    };

  fileSystems."/zstorage/quick_share" =
    { device = "zstorage/quick_share";
      fsType = "zfs";
    };

  fileSystems."/zstorage/sites" =
    { device = "zstorage/sites";
      fsType = "zfs";
    };

  fileSystems."/zstorage/users" =
    { device = "zstorage/users";
      fsType = "zfs";
    };

  fileSystems."/zstorage/users/lucas" =
    { device = "zstorage/users/lucas";
      fsType = "zfs";
    };

  fileSystems."/zstorage/users/zeus" =
    { device = "zstorage/users/zeus";
      fsType = "zfs";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/1384336b-01be-4d13-9e15-6f71a5d3005c"; priority = 10; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}

# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "zchuck/nixos";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/35DD-8B37";
      fsType = "vfat";
    };

  fileSystems."/drive_c" =
    { device = "/dev/zd16p3";
      fsType = "ntfs";
    };

  fileSystems."/nix" =
    { device = "zchuck/nix_store";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/pcbackup/drive_d" =
    { device = "zhuge2/pcbackup/drive_d";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/testing" =
    { device = "zhuge2/testing";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zgaming/origin" =
    { device = "zhuge2/zgaming/origin";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zgaming/origin/master" =
    { device = "zhuge2/zgaming/origin/master";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zgaming/steam/master" =
    { device = "zhuge2/zgaming/steam/master";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zgaming/archives/master" =
    { device = "zhuge2/zgaming/archives/master";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zstorage/apps_drivers" =
    { device = "zhuge2/zstorage/apps_drivers";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zstorage/games_stuff" =
    { device = "zhuge2/zstorage/games_stuff";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zstorage/movies" =
    { device = "zhuge2/zstorage/movies";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zstorage/music" =
    { device = "zhuge2/zstorage/music";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zstorage/pc_backups" =
    { device = "zhuge2/zstorage/pc_backups";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zstorage/pictures_videos" =
    { device = "zhuge2/zstorage/pictures_videos";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zstorage/plex" =
    { device = "zhuge2/zstorage/plex";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zstorage/plex/config" =
    { device = "zhuge2/zstorage/plex/config";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zstorage/plex/transcode" =
    { device = "zhuge2/zstorage/plex/transcode";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zstorage/quick_share" =
    { device = "zhuge2/zstorage/quick_share";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zstorage/sites" =
    { device = "zhuge2/zstorage/sites";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zstorage/users" =
    { device = "zhuge2/zstorage/users";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zstorage/users/lucas" =
    { device = "zhuge2/zstorage/users/lucas";
      fsType = "zfs";
    };

  fileSystems."/zhuge2/zstorage/users/zeus" =
    { device = "zhuge2/zstorage/users/zeus";
      fsType = "zfs";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/78e29356-990f-4dd8-a9b8-fa4efd01a9a9"; }
    ];

  virtualisation.hypervGuest.enable = true;
}
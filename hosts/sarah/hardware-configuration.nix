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
    { device = "zsarah/nixos/root";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-partuuid/5f49f8ef-06e6-4e38-a534-dfaeed505102";
      fsType = "vfat";
    };

  fileSystems."/nix" =
    { device = "zsarah/nixos/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "zsarah/home";
      fsType = "zfs";
    };

  fileSystems."/var" =
    { device = "zsarah/nixos/var";
      fsType = "zfs";
    };

  fileSystems."/zhuge1/games" =
    { device = "zhuge1/games";
      fsType = "zfs";
    };

  fileSystems."/zhuge1/zstorage/apps_drivers" =
    { device = "zhuge1/zstorage/apps_drivers";
      fsType = "zfs";
    };

  fileSystems."/zhuge1/zstorage/games_stuff" =
    { device = "zhuge1/zstorage/games_stuff";
      fsType = "zfs";
    };

  fileSystems."/zhuge1/zstorage/movies" =
    { device = "zhuge1/zstorage/movies";
      fsType = "zfs";
    };

  fileSystems."/zhuge1/zstorage/music" =
    { device = "zhuge1/zstorage/music";
      fsType = "zfs";
    };

  fileSystems."/zhuge1/zstorage/pc_backups" =
    { device = "zhuge1/zstorage/pc_backups";
      fsType = "zfs";
    };

  fileSystems."/zhuge1/zstorage/pictures_videos" =
    { device = "zhuge1/zstorage/pictures_videos";
      fsType = "zfs";
    };

  fileSystems."/zhuge1/zstorage/plex" =
    { device = "zhuge1/zstorage/plex";
      fsType = "zfs";
    };

  fileSystems."/zhuge1/zstorage/plex/config" =
    { device = "zhuge1/zstorage/plex/config";
      fsType = "zfs";
    };

  fileSystems."/zhuge1/zstorage/plex/transcode" =
    { device = "zhuge1/zstorage/plex/transcode";
      fsType = "zfs";
    };

  fileSystems."/zhuge1/zstorage/quick_share" =
    { device = "zhuge1/zstorage/quick_share";
      fsType = "zfs";
    };

  fileSystems."/zhuge1/zstorage/sites" =
    { device = "zhuge1/zstorage/sites";
      fsType = "zfs";
    };

  fileSystems."/zhuge1/zstorage/users" =
    { device = "zhuge1/zstorage/users";
      fsType = "zfs";
    };

  fileSystems."/zhuge1/zstorage/users/lucas" =
    { device = "zhuge1/zstorage/users/lucas";
      fsType = "zfs";
    };

  fileSystems."/zhuge1/zstorage/users/zeus" =
    { device = "zhuge1/zstorage/users/zeus";
      fsType = "zfs";
    };

  swapDevices =
    [ { device = "/dev/disk/by-partuuid/dde342a2-f828-4e6e-9acb-b7afd32821ae"; }
    ];

  virtualisation.hypervGuest.enable = true;
}

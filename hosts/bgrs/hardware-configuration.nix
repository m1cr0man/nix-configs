# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:
let
  secrets = import ../../common/secrets.nix;
in {
  imports = [ ];

  boot.initrd.availableKernelModules = [ "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "zroot/nixos";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zroot/nixos/store";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/D415-73CA";
      fsType = "vfat";
    };

  systemd.targets.network.before = [ "zeuspc.mount" ];
  fileSystems."/zeuspc" =
    { device = "//192.168.14.100/d$";
      fsType = "cifs";
      options = [
        "nofail"
        "username=zeus"
        "password=${secrets.bgrs_cifs_password}"
      ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/96a2e8c7-dbe8-4ee4-a38b-cf2d6199438d"; }
    ];

  virtualisation.hypervGuest.enable = true;
}

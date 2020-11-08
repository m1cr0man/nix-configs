{ lib, pkgs, modulesPath, ... }:
let
  server = "192.168.14.2";
in {
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd = {
    availableKernelModules = [ "overlay" "xhci_pci" "xhci_hcd" "ehci_pci" "ahci" "usbhid" "uas" "sd_mod" "e1000e" "r8169" ];
    kernelModules = [ "nfsv3" "nfs" "sunrpc" "nfs_acl" "lockd" ];
    supportedFilesystems = [ "nfs" "overlay" ];
  };

  boot.supportedFilesystems = [ "nfs" "overlay" "zfs" ];
  boot.zfs.enableUnstable = true;

  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Fixes buggy loading of the Renesas USB3 controller
  boot.initrd.preDeviceCommands = ''
    rmmod xhci_pci
    rmmod xhci_hcd
    echo 1 > '/sys/bus/pci/devices/0000:02:00.0/reset'
    modprobe xhci_hcd
    modprobe xhci_pci
  '';

  fileSystems."/" =
    { fsType = "tmpfs";
      options = [ "mode=0755" ];
    };

  fileSystems."/nix/.ro-store" =
    { device = "${server}:/exports/netboot/nix_store/store";
      fsType = "nfs";
      neededForBoot = true;
      options = [
        "vers=3"
        "ro"
        "noatime"
        "nodiratime"
        "nocto"
        "ac"
        "actimeo=43200"
        "nolock"
        "local_lock=all"
        "lookupcache=all"
      ];
    };

  fileSystems."/nix/store" =
    { fsType = "overlay";
      device = "overlay";
      options = [
        "lowerdir=/nix/.ro-store"
        "upperdir=/nix/.rw-store/upper"
        "workdir=/nix/.rw-store/work"
      ];
    };

  fileSystems."/home" =
    { device = "${server}:/home";
      fsType = "nfs";
      options = [
        "vers=3"
        "noatime"
        "nodiratime"
        "ac"
        "actimeo=43200"
        "nolock"
        "local_lock=all"
        "lookupcache=all"
      ];
    };

  fileSystems."/games/nfs" =
    { device = "${server}:/exports/games";
      fsType = "nfs";
      options = [
        "vers=3"
        "noatime"
        "nodiratime"
        "ac"
        "actimeo=43200"
        "nolock"
        "local_lock=all"
        "lookupcache=pos"
      ];
    };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}

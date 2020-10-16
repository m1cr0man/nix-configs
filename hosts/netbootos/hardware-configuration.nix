{ lib, pkgs, modulesPath, ... }:
let
  server = "192.168.14.2";
in {
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd = {
    availableKernelModules = [ "overlay" "xhci_pci" "xhci_hcd" "ehci_pci" "ahci" "usbhid" "uas" "sd_mod" "e1000e" "r8169" ];
    kernelModules = [ "nfsv4" ];
    supportedFilesystems = [ "nfs" "overlay" ];
  };

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
        "vers=4.2"
        "addr=${server}"
        "ro"
      ];
    };

  fileSystems."/nix/.rw-store" =
    { fsType = "tmpfs";
      options = [ "mode=0755" ];
      neededForBoot = true;
    };

  fileSystems."/nix/store" =
    { fsType = "overlay";
      device = "overlay";
      options = [
        "lowerdir=/nix/.ro-store"
        "upperdir=/nix/.rw-store/store"
        "workdir=/nix/.rw-store/work"
      ];
    };

  fileSystems."/home" =
    { device = "${server}:/exports/netboot/homes";
      fsType = "nfs";
      options = [
        "vers=4.2"
        "addr=${server}"
      ];
    };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}

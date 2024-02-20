{ config, lib, ... }: {
  users.mutableUsers = false;

  networking = {
    useDHCP = true;
    useNetworkd = true;
  };

  microvm = {
    vcpu = lib.mkDefault 4;
    mem = lib.mkDefault 8192;
    kernelParams = [ "systemd.journald.forward_to_console=1" ];

    # It is highly recommended to share the host's nix-store
    # with the VMs to prevent building huge images.
    shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "ro-store";
        proto = "virtiofs";
      }
      {
        source = "etc";
        mountPoint = "/etc";
        tag = "etc";
        proto = "virtiofs";
      }
      {
        source = "var";
        mountPoint = "/var";
        tag = "var";
        proto = "virtiofs";
      }
    ];
  };
}

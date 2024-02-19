{ pkgs, lib, self, ... }: let
  baseConfig = { config, ... }: let
    name = config.networking.hostName;
  in {
    imports = (lib.m1cr0man.module.addModules "${self}/modules" [
      "global-options.nix"
      "sysconfig/core.nix"
      "sysconfig/users-groups.nix"
      "management/ssh"
    ]);

    system.stateVersion = "24.05";

    microvm.vcpu = 4;
    microvm.mem = 8192;
    microvm.kernelParams = [ "systemd.journald.forward_to_console=1" ];

    # It is highly recommended to share the host's nix-store
    # with the VMs to prevent building huge images.
    microvm.shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "ro-store";
        proto = "virtiofs";
      }
      {
        source = "/var/lib/microvms/kube-master/etc";
        mountPoint = "/etc";
        tag = "etc";
        proto = "virtiofs";
      }
      {
        source = "/var/lib/microvms/kube-master/var";
        mountPoint = "/var";
        tag = "var";
        proto = "virtiofs";
      }
    ];

    users.mutableUsers = false;

    networking = {
      useDHCP = true;
      useNetworkd = true;
    };

    systemd.network.enable = true;
  };
in {

  microvm.vms = {
    kube-master = {
      # The package set to use for the microvm. This also determines the microvm's architecture.
      # Defaults to the host system's package set if not given.
      inherit pkgs;

      # (Optional) A set of special arguments to be passed to the MicroVM's NixOS modules.
      #specialArgs = {};

      # The configuration for the MicroVM.
      # Multiple definitions will be merged as expected.
      config = {
        imports = [
          baseConfig
        ];

        networking.hostName = "kube-master";

        microvm.interfaces = [{
          type = "tap";
          id = "vm-kube-master";
          mac = "12:34:56:00:00:01";
        }];

        systemd.network.networks."20-lan" = {
          matchConfig.Type = "ether";
          networkConfig = {
            Address = ["192.168.32.2/24" "fd12:3456:789a::2/64"];
            Gateway = "192.168.32.1";
            DNS = ["1.1.1.1"];
            IPv6AcceptRA = true;
            DHCP = "no";
          };
        };

        environment.systemPackages = with pkgs; [
          kompose
          kubectl
          kubernetes
        ];

        services.kubernetes = {
          roles = ["master" "node"];
          masterAddress = "127.0.0.1";
          easyCerts = true;
        };
      };
    };
  };
}

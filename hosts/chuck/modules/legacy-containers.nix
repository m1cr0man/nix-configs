let
  mcConfig = {
    enable = true;
    eula = true;
    declarative = true;
    openFirewall = true;
  };
in
{
  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
    externalInterface = "eth1";
    enableIPv6 = true;
  };

  containers.minecraft = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";
    config = { pkgs, config, lib, ... }: {
      nixpkgs.config.allowUnfree = true;
      system.stateVersion = "24.05";
      services.minecraft-server = mcConfig;

      networking = {
        firewall.enable = true;
        useHostResolvConf = lib.mkForce false;
      };
      services.resolved.enable = true;
    };
  };

  nixos.containers.instances.minecraftnew = {
    ephemeral = true;
    activation.autoStart = true;

    network = {
      v4.static = {
        hostAddresses = [ "192.168.101.10/24" ];
        containerPool = [ "192.168.101.11/24" ];
      };
      v6.static = {
        hostAddresses = [ "fc01::1/64" ];
        containerPool = [ "fc01::2/64" ];
      };
    };

    system-config = {...}: {
      system.stateVersion = "24.05";
      services.minecraft-server = mcConfig;
    };
  };
}

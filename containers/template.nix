let
  secrets = import ../common/secrets.nix;
  hostPath = "HOSTPATH";
in {

  containers.CONTAINERNAME = {
    autoStart = true;
    bindMounts."/CONTAINERNAME" = {
      inherit hostPath;
      isReadOnly = false;
      mountPoint = "/CONTAINERNAME";
    };
  };

  containers.CONTAINERNAME.config =
    { config, pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
    };

  networking.firewall.allowedTCPPorts = [ "EXPORTED_PORTS" ];
}

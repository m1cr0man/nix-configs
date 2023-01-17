{ lib, modulesPath, ... }:
let
  inherit (lib) types mkOption;
in
{
  config = {
    boot.isContainer = true;

    users.mutableUsers = false;
    users.allowNoPasswordLogin = true;

    networking = {
      useHostResolvConf = false;
      useDHCP = false;
      useNetworkd = true;
    };

    nixosContainer = {
      ephemeral = true;
      bridge = "br-containers";
      activation.strategy = lib.mkDefault "reload";
      bindMounts = [
        # Required to read host key to decrypt sops secrets
        "/etc/ssh"
        # Required to access certificates managed on the host
        "/var/lib/acme"
        # Required for sharing UNIX sockets between containers
        "/var/lib/sockets"
      ];
    };
  };
}

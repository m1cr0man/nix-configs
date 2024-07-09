{ config, lib, modulesPath, ... }:
let
  inherit (lib) types mkOption;
in
{
  config = {
    networking = {
      nameservers = [ "1.1.1.1" "8.8.8.8" ];
      hosts."${config.m1cr0man.container.hostAddress}" = [
        "containerhost" "containerhost.local"
      ];
      # Enable LLMNR
      firewall.allowedUDPPorts = [ 5355 ];
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

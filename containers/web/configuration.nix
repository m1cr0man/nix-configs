{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "secrets"
      "servers/headscale.nix"
      "www/acme-base.nix"
      "www/httpd.nix"
      "www/matrix.nix"
      "www/plex.nix"
    ]
    ++
    addModulesRecursive ./modules;

  system.stateVersion = "24.05";

  nixosContainer =
    {
      forwardPorts =
        builtins.map
          (port: { hostPort = port; containerPort = port; })
          [
            80
            443
            # Plex
            32400
          ];
      bindMounts = [
        "${stateDir}/nixos:/var/lib/nixos"
        "${stateDir}/headscale:/var/lib/headscale"
        "${stateDir}/matrix-synapse:/var/lib/matrix-synapse"
        "${stateDir}/minio:/var/lib/minio"
        "${stateDir}/nextcloud:/var/lib/nextcloud"
        "${stateDir}/plex:/var/lib/plex"
        "${stateDir}/rainloop:/var/lib/rainloop"
        "${stateDir}/julia:/var/lib/julia"
      ];
    };

  networking.hosts."${config.m1cr0man.container.hostAddress}" = [ "containerhost.local" ];
}

{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "secrets"
      "monitoring/client"
      "servers/headscale.nix"
      "www/acme-base.nix"
      "www/httpd.nix"
      "www/matrix.nix"
    ]
    ++
    addModulesRecursive ./modules;

  system.stateVersion = "25.11";

  nixosContainer =
    {
      forwardPorts =
        builtins.map
          (port: { hostPort = port; containerPort = port; })
          [
            80
            443
          ];
      bindMounts = [
        "${stateDir}/nixos:/var/lib/nixos"
        "${stateDir}/headscale:/var/lib/headscale"
        "${stateDir}/matrix-synapse:/var/lib/matrix-synapse"
        "${stateDir}/minio:/var/lib/minio"
        "${stateDir}/nextcloud:/var/lib/nextcloud"
        # TODO bind appdata/preview onto ssd
        "${stateDir}/plex:/var/lib/plex"
        "${stateDir}/rainloop:/var/lib/rainloop"
        "${stateDir}/julia:/var/lib/julia"
      ];
    };
}

{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "secrets"
      "www/acme-base.nix"
      "www/httpd.nix"
      "www/matrix.nix"
      "www/minio.nix"
      "www/plex.nix"
    ]
    ++
    addModulesRecursive ./modules;

  system.stateVersion = "22.11";

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
        "${stateDir}/matrix-synapse:/var/lib/matrix-synapse"
        "${stateDir}/minio:/var/lib/minio"
        "${stateDir}/plex:/var/lib/plex"
      ];
    };

  # Map postgres server to host
  networking.hosts."${config.m1cr0man.container.hostAddress}" = [ "postgresql.local" "containerhost.local" ];
}
{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "secrets"
      "monitoring/client"
    ]
    ++
    addModulesRecursive ./modules;

  system.stateVersion = "25.11";

  services.vector.enable = lib.mkForce false;

  nixosContainer =
    {
      forwardPorts =
        builtins.map
          (port: { hostPort = port; containerPort = port; })
          [
          ];
      bindMounts = [
        stateDir
        "${stateDir}/storage:/var/lib/containers/storage"
      ];
      # Allows Podman/Docker to use keyctl inside the container
      # https://mwalkowski.com/post/container-inception-docker-in-nspawn-container/
      systemCallFilter = "@keyring bpf keyctl";
    };
}

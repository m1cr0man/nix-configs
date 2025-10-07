{ config, pkgs, lib, ... }:
{
  options.m1cr0man.openspy-containers = {
    stateDir = lib.mkOption {
      readOnly = true;
      type = lib.types.str;
      description = "Where stateful configuration is stored";
      default = "${config.m1cr0man.container.stateDir}/openspy";
    };
    containers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({ config, name, ... }: {
        options = {
          autoStart = lib.mkOption {
            type = lib.types.bool;
            description = "Whether to autostart the container";
            default = false;
          };
          hostname = lib.mkOption {
            type = lib.types.str;
            description = "Container hostname";
            default = name;
            defaultText = "same as key";
          };
          image = lib.mkOption {
            type = lib.types.str;
            description = "Image to use";
          };
          ports = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "Ports to expose";
            default = [ ];
          };
          environment = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            description = "Environment variables to set";
            default = { };
          };
          volumes = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "Volumes to mount";
            default = [ ];
          };
          extraOptions = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "Extra options to pass to podman run";
            default = [ ];
          };
          environmentFiles = lib.mkOption {
            type = lib.types.listOf lib.types.path;
            description = "Environment files to pass to podman run";
            default = [ ];
          };
          entrypoint = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            description = "Path to an alternative entrypoint";
            default = null;
          };
          cmd = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "CLI args to pass to the entrypoint";
            default = [];
          };
        };
      }));
    };
  };

  config = {
    virtualisation.podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    virtualisation.containers = {
      enable = true;
      # fixes Error: crun: join keyctl Operation not permitted: OCI permission denied
      # FIXME Could be https://stackoverflow.com/questions/72390693/cant-create-new-session-keyring-with-keyctl
      containersConf.settings.containers.keyring = false;
    };

    networking.firewall.trustedInterfaces = [ "podman0" ];

    virtualisation.oci-containers.containers = lib.mapAttrs (hostname: cfg: {
      inherit (cfg) autoStart hostname image ports environmentFiles entrypoint cmd;
      environment = {
        ASPNETCORE_ENVIRONMENT = "development";
      } // cfg.environment;
      volumes = [
        "${config.m1cr0man.openspy-containers.stateDir}:/state"
        "/var/lib/sockets:/var/lib/sockets"
        "/run/mysqld:/run/mysqld"
        # Fixes Error: crun: mount `proc` to `proc`: Operation not permitted: OCI permission denied.
        # See https://github.com/containers/podman/discussions/22010#discussioncomment-8750445
        "/proc:/proc"
      ] ++ cfg.volumes;
      extraOptions = [
        # "--uidmap=0:1000:1"
        # "--gidmap=0:1000:1"
        # "--gidmap=40:40:1"
        # Also part of proc mount fix
        "--pid=host"
      ] ++ cfg.extraOptions;
    }) config.m1cr0man.openspy-containers.containers;
  };

  # If actually trying to run as user 1000:
  # add podman.user = "openspy";
  # add flag "--cgroups=no-conmon" (Maybe)
  # enable autoSubUidGidRange and linger on the user
  # `podman system migrate` (Maybe)
  # systemd.services = lib.mapAttrs' (name: value: lib.nameValuePair ("podman-" + name) {
  #   serviceConfig = {
  #     Group = "openspy";
  #     Delegate = "yes";
  #     WorkingDirectory = "%t/core-web";
  #   };
  # });
}

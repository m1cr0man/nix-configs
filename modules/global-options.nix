# This file defines options that are used in many of the modules
# in this repository.
{ lib, config, ... }:
let
  cfg = config.m1cr0man;
in
{
  options.m1cr0man = with lib; {
    domain = mkOption {
      default = config.networking.domain;
      defaultText = "Copied from config.networking.domain";
      type = types.str;
      description = "Domain name used across most configuration files.";
    };

    adminEmail = mkOption {
      type = types.str;
      default = "admin@${cfg.domain}";
      defaultText = "admin@\${config.m1cr0man.domain}";
      description = "Admin email address for ACME, HTTPd, and other services.";
    };

    instanceType = mkOption {
      type = types.str;
      default = "host";
      description = "Type of instance being deployed. Valid values are host or container.";
    };

    container = {
      hostAddress = mkOption {
        type = types.str;
        default = "beef::1";
        description = "Address of the container's host.";
      };

      stateDir = mkOption {
        type = types.path;
        default = "/var/lib/containers/${config.networking.hostName}";
        description = "Folder where the container's state can be saved.";
      };
    };
  };
}

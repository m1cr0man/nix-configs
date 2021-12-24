{ pkgs, lib, ... }:
with lib;
with types;
let
  serverOpts = { name, ... }: {
    options = {
      enable = mkEnableOption "this Minecraft server";
      name = mkOption {
        type = str;
        default = name;
        description = "Server name, and subfolder to use.";
      };
      memGb = mkOption {
        type = int;
        default = 2;
        description = "Max memory to allocate";
      };
      jar = mkOption {
        type = oneOf [ path str ];
        default = 2;
        description = "Jar file";
      };
      jre = mkOption {
        type = path;
        default = pkgs.jdk17_headless;
        description = "Java package to use";
      };
      port = mkOption {
        type = int;
        default = 25565;
        description = "Main port";
      };
      serverProperties = mkOption {
        type = attrs;
        default = { motd = name; };
        description = "server.properties attributes";
      };
      user = mkOption {
        type = str;
        # TODO use dynamic user if not exists
        default = "minecraft";
        description = "Server service user for filesystem permissions";
      };
      group = mkOption {
        type = str;
        default = "nogroup";
        description = "Server service group for filesystem permissions";
      };
      zramSizeGb = mkOption {
        type = int;
        default = 0;
        description = "Size of allocated ZRAM disk, if any";
      };
      zramDevice = mkOption {
        type = str;
        default = "/dev/zram0";
        description = "ZRAM device to use";
      };
    };
  };

in {
  options.m1cr0man.minecraft-servers = mkOption {
    default = {};
    type = attrsOf (submodule serverOpts);
  };
}

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
      launchCommand = mkOption {
        type = nullOr str;
        default = null;
        description = "Alternative command to use to launch the server as opposed to java";
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
        default = "minecraft";
        description = "Server service group for filesystem permissions";
      };
      ramfsDirectory = mkOption {
        type = nullOr path;
        default = null;
        description = "Absolute path to ramfs directory to use to run server from.";
      };
      stateDirectory = mkOption {
        type = str;
        default = "/var/lib/gaming/minecraft/${name}";
        description = "Where to store game files";
      };
    };
  };

in
{
  options.m1cr0man.minecraft-servers = mkOption {
    default = { };
    type = attrsOf (submodule serverOpts);
  };
}

{ lib, ... }:
with lib;
with types;
let
  serverOpts = { name, ... }: {
    options = {
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
    };
  };

in {
  options.m1cr0man.minecraft-servers = mkOption {
    default = {};
    type = attrsOf (submodule serverOpts);
  };
}

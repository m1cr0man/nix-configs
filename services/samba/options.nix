{ lib, ... }:
with lib;
with types;
let
  shareOpts = { name, ... }: {
    options = {
      name = mkOption {
        type = str;
        default = name;
        description = "Share name";
      };
      path = mkOption {
        type = oneOf [ path str ];
        default = 2;
        description = "Share filesystem path";
      };
      comment = mkOption {
        type = str;
        default = "NixOS managed Samba share";
        description = "Friendly description";
      };
      extraConfig = mkOption {
        type = attrs;
        default = { };
        description = "Extra share config";
      };
    };
  };

in {
  options.m1cr0man.samba-shares = mkOption {
    default = {};
    type = attrsOf (submodule shareOpts);
  };
  options.m1cr0man.samba-home-shares = mkOption {
        type = bool;
        default = true;
        description = "Enable home shares";
  };
}

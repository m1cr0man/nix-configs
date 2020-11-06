{ lib, ... }:
{
  options.m1cr0man.chronograf.reverseProxy = lib.mkOption {
    default = true;
    type = lib.types.nullOr lib.types.bool;
  };
}

{ lib, ... }:
with lib;
{
  options.m1cr0man.chronograf.reverseProxy = mkOption {
    default = true;
    type = types.bool;
  };
  options.m1cr0man.influxdb.bindAddress = mkOption {
    default = "127.0.0.1";
    type = types.str;
  };
}

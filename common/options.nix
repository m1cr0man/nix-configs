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
  options.m1cr0man.netbooter.dhcpRange = mkOption {
    default = null;
    type = types.nullOr types.str;
    description = "Pair of IP addresses (comma separated) of range for leases";
  };
  options.m1cr0man.netbooter.dhcpProxyAddress = mkOption {
    default = null;
    type = types.nullOr types.str;
    description = "Listening range for DHCP proxying";
  };
  options.m1cr0man.netbooter.hostIp = mkOption {
    default = "192.168.137.2";
    type = types.str;
    description = "Address of this host AKA the PXE boot server";
  };
}

{ config, lib, ... }:
let
  address = "0.0.0.0:9137";
in
{
  services.systemd-exporterd = {
    enable = config.m1cr0man.monitoring.systemdMetrics;
    listenerAddress = address;
    monitorUserManagers = true;
    includeFilters = [ "\\.service$" "\\.timer$" ];
  };
}

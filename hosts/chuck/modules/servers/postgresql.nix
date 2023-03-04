{ pkgs, lib, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    extraPlugins = with pkgs.postgresql_15.pkgs; [ postgis timescaledb ];
    ensureDatabases = [ "pathfinder" ];
    enableTCPIP = true;
    authentication = ''
      host all all 192.168.0.0/16 md5
      host all all 192.168.0.0/16 scram-sha-256
      host all all 192.168.0.0/16 password
    '';
    settings = {
      log_connections = true;
      log_statement = "all";
      logging_collector = true;
      log_disconnections = true;
      log_destination = lib.mkForce "syslog";
    };
  };

  networking.firewall.allowedTCPPorts = [ 5432 ];
}

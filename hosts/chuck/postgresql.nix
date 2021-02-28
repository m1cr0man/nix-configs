{ lib, ... }:
{
  services.postgresql.ensureDatabases = [ "pathfinder" ];
  services.postgresql.enableTCPIP = true;
  services.postgresql.authentication = ''
    host all all 192.168.0.0/16 md5
    host all all 192.168.0.0/16 scram-sha-256
    host all all 192.168.0.0/16 password
  '';
  services.postgresql.settings = {
    log_connections = true;
    log_statement = "all";
    logging_collector = true;
    log_disconnections = true;
    log_destination = lib.mkForce "syslog";
  };
  networking.firewall.allowedTCPPorts = [ 5432 ];
}

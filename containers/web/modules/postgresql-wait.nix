{ config, lib, ... }:
{
  # Will not auto start - depended on by other services that will handle it.
  # Will exit 1 if it stops existing too - for graceful restarting of dependencies.
  systemd.services.postgresql-wait = {
    after = [ "network.target" "local-fs.target" ];
    description = "Wait for postgresql to come online";
    preStart = ''
      while test ! -e /var/lib/sockets/.s.PGSQL.5432; do
        echo "Waiting for PostgreSQL socket"
        sleep 2
      done
    '';
    script = ''
      echo "Postgresql is online. Will continue to monitor its status."
      while test -e /var/lib/sockets/.s.PGSQL.5432; do
        sleep 2
      done
      echo "Postgresql died!"
      exit 1
    '';
    unitConfig.RequiresMountsFor = "/var/lib/sockets";
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 10;
    };
  };

  # Make matrix wait for postgres
  systemd.services.matrix-synapse = lib.mkIf (config.services.matrix-synapse.enable) {
    after = [ "postgresql-wait.service" ];
    bindsTo = [ "postgresql-wait.service" ];
    serviceConfig = {
      Restart = lib.mkForce "always";
      RestartSec = 10;
    };
  };
}

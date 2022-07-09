{
  # Allow other hosts on the bridge to connect to postgresql
  networking.firewall.allowedTCPPorts = [ 5432 ];

  services.postgresql = {
    ensureUsers = [
      rec {
        name = "matrix-synapse";
        ensurePermissions."DATABASE \"${name}\"" = "ALL PRIVILEGES";
      }
    ];
  };

  m1cr0man.postgresql.startupCommands = ''
    CREATE DATABASE "matrix-synapse" TEMPLATE template0 LC_COLLATE = "C" LC_CTYPE = "C";
  '';
}

{ config, lib, ... }:
let
  sopsSuffix = "_database_hashed_password";
  mkUser = sopsKey: {
    hashedPasswordFile = config.sops.secrets."${sopsKey}".path;
    home = "/var/empty";
    createHome = false;
    isSystemUser = true;
    useDefaultShell = false;
    group = "sockets";
  };
in
{
  # Set passwords for each user
  users.users.matrix-synapse = mkUser "matrix_synapse${sopsSuffix}";
  users.users.nextcloud = mkUser "nextcloud${sopsSuffix}";
  users.users.rainloop = mkUser "rainloop${sopsSuffix}";

  sops.secrets."matrix_synapse${sopsSuffix}".neededForUsers = true;
  sops.secrets."nextcloud${sopsSuffix}".neededForUsers = true;
  sops.secrets."rainloop${sopsSuffix}".neededForUsers = true;

  services.postgresql = {
    # Not needed - everything uses sockets
    enableTCPIP = false;
    ensureUsers = [
      {
        name = "matrix-synapse";
        ensureClauses.login = true;
      }
      {
        name = "nextcloud";
        ensureDBOwnership = true;
        ensureClauses.login = true;
      }
      {
        name = "rainloop";
        ensureClauses.login = true;
      }
    ];
    ensureDatabases = [
      "nextcloud"
      "rainloop-contacts"
    ];
  };

  systemd.services.postgresql.postStart = lib.mkAfter ''
    if ! ( $PSQL -tAc "SELECT 1 FROM pg_database WHERE datname = 'matrix-synapse'" | grep -q 1 ); then
      $PSQL -tAc 'CREATE DATABASE "matrix-synapse" TEMPLATE template0 LC_COLLATE = "C" LC_CTYPE = "C"'
      $PSQL -tAC 'ALTER DATABASE "matrix-synapse" OWNER TO "matrix-synapse";'
    fi
    $PSQL -tAc 'ALTER DATABASE "rainloop-contacts" OWNER TO "rainloop";'
  '';
}

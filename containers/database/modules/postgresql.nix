{ config, ... }:
let
  sopsSuffix = "_database_hashed_password";
  mkUser = sopsKey: {
    passwordFile = config.sops.secrets."${sopsKey}".path;
    home = "/var/empty";
    createHome = false;
    isSystemUser = true;
    useDefaultShell = false;
    group = "sockets";
  };
in
{
  # Allow other hosts on the bridge to connect to postgresql
  networking.firewall.allowedTCPPorts = [ 5432 ];

  # Set passwords for each user
  users.users.matrix-synapse = mkUser "matrix_synapse${sopsSuffix}";
  users.users.nextcloud = mkUser "nextcloud${sopsSuffix}";
  users.users.rainloop = mkUser "rainloop${sopsSuffix}";

  sops.secrets."matrix_synapse${sopsSuffix}".neededForUsers = true;
  sops.secrets."nextcloud${sopsSuffix}".neededForUsers = true;
  sops.secrets."rainloop${sopsSuffix}".neededForUsers = true;

  services.postgresql = {
    ensureUsers = [
      rec {
        name = "matrix-synapse";
        ensurePermissions."DATABASE \"${name}\"" = "ALL PRIVILEGES";
      }
      rec {
        name = "nextcloud";
        ensurePermissions."DATABASE \"${name}\"" = "ALL PRIVILEGES";
      }
      {
        name = "rainloop";
        ensurePermissions."DATABASE \"rainloop-contacts\"" = "ALL PRIVILEGES";
      }
    ];
    ensureDatabases = [
      "nextcloud"
      "rainloop-contacts"
    ];
  };

  m1cr0man.postgresql.startupCommands = ''
    CREATE DATABASE "matrix-synapse" TEMPLATE template0 LC_COLLATE = "C" LC_CTYPE = "C";
  '';
}

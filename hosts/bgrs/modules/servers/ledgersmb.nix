{ config, pkgs, ... }:
let
  user = "ledgersmb";
  dbUser = "lsmb_dbadmin";
  uid = 2002;
  gid = 2002;
in
{
  users.users."${user}" = {
    inherit uid;
    group = user;
    isSystemUser = true;
    home = "/var/empty";
    createHome = false;
  };

  users.groups."${user}" = {
    inherit gid;
  };

  virtualisation = {
    podman.extraPackages = [ pkgs.zfsUnstable ];

    oci-containers = {
      backend = "podman";

      containers.ledgersmb = {
        user = with builtins; "${toString uid}:${toString gid}";
        image = "ledgersmb/ledgersmb:1.9.8";
        autoStart = true;
        ports = [ "127.0.0.1:5762:5762/tcp" ];
        environment = {
          POSTGRES_HOST = "10.88.0.1";
          LSMB_WORKERS = "2";
        };
      };
    };

    containers.storage.settings.storage = {
      driver = "zfs";
      options.zfs = {
        fsname = "zroot/containers";
      };
      graphroot = "/var/lib/containers/storage";
      runroot = "/run/containers/storage";
    };
  };

  systemd.services."ledgersmb-setup-db" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
    requiredBy = [ "podman-ledgersmb.service" ];
    before = [ "podman-ledgersmb.service" ];
    path = [ config.services.postgresql.package ];
    script = ''
      if ! psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='${dbUser}'" | grep -q 1; then
        psql -tAc 'CREATE USER "${dbUser}" WITH PASSWORD '"'$LEDGERSMB_PASSWORD'"
      fi
      set -x
      psql -tAc 'ALTER ROLE "${dbUser}" CREATEROLE'
      psql -tAc 'ALTER ROLE "${dbUser}" CREATEDB'
      psql -tAc 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "${dbUser}"'
    '';
    serviceConfig = {
      User = "postgres";
      Group = "postgres";
      Type = "oneshot";
      EnvironmentFile = config.sops.secrets.ledgersmb_setup_env.path;
    };
  };

  sops.secrets.ledgersmb_setup_env = { };
}

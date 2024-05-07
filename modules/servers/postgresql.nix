{ config, lib, pkgs, ... }:
let
  cfg = config.m1cr0man.postgresql;

  package = cfg.package.overrideAttrs (prev: {
    buildInputs = prev.buildInputs ++ [ pkgs.pam ];
    configureFlags = prev.configureFlags ++ [ "--with-pam" ];
  });
  startupScript = pkgs.writeText "postgres-startup-commands" cfg.startupCommands;
  localDomain = "postgresql.local";

  hasTCPIP = config.services.postgresql.enableTCPIP;
in
{
  options.m1cr0man.postgresql = with lib; {
    startupCommands = mkOption {
      default = "";
      type = types.lines;
      description = "Commands to run on each startup of the database";
    };
    package = mkOption {
      default = pkgs.postgresql_16;
      type = types.path;
      description = ''
        PostgreSQL package to run. Note when upgrading major versions the
        data directory will change + migration must be performed.
      '';
    };
  };

  config = lib.mkMerge [
  (lib.mkIf (hasTCPIP) {
    users.users.postgres.extraGroups = [ "acme" ];

    services.postgresql = {
      authentication = ''
        hostssl all all 192.168.0.0/16 cert
        hostssl all all beef::/64      cert
      '';
      settings = {
        ssl = true;
        ssl_ciphers = "HIGH:+3DES:!aNULL";
        ssl_dh_params_file = "${config.security.dhparams.params.postgresql.path}";
        ssl_ca_file = "/var/lib/acme/${localDomain}/ca/cert.pem";
        ssl_cert_file = "/var/lib/acme/${localDomain}/server/cert.pem";
        ssl_key_file = "/var/lib/acme/${localDomain}/server/key.pem";
      };
    };

    systemd.services.postgresql-certs =
      let
        inherit (builtins) concatStringsSep map;
        users = concatStringsSep " " (map (v: "'${v.name}'") config.services.postgresql.ensureUsers);
      in
      {
        requiredBy = [ "postgresql.service" ];
        before = [ "postgresql.service" ];
        after = [ "acme-fixperms.service" ];
        description = "Generate self signed certificates for Postgresql";
        path = [ pkgs.minica ];
        environment.DOMAIN = localDomain;
        script = ''
          if [ ! -e server/cert.pem ]; then
            mkdir -p ca
            minica \
              -ca-cert ca/cert.pem \
              -ca-key ca/key.pem \
              -domains "$DOMAIN"
            mv "$DOMAIN" server
          fi
          # Generate certs for each user
          for user in ${users}; do
            if [ ! -e "$user" ]; then
              minica \
                -ca-cert ca/cert.pem \
                -ca-key ca/key.pem \
                -domains "$user"
            fi
          done
        '';
        # Separated into postStart so that other scripts
        # can insert cert generation if they want
        postStart = ''
          chmod -R u=rwX,g=rX,o= .
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          Group = "acme";
          UMask = 0027;
          StateDirectoryMode = 0750;
          StateDirectory = "acme/${localDomain}";
          WorkingDirectory = "/var/lib/acme/${localDomain}";
        };
      };

    security.dhparams = {
      enable = true;
      defaultBitSize = 2048;
      params.postgresql = { };
    };

  })
  {
    systemd.services.postgresql-startup-commands = {
      wantedBy = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
      description = "Runs database scripts on each postgres startup";
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
        ExecStart = "${package}/bin/psql -d postgres -f '${startupScript}'";
      };
    };

    security.pam.services.postgresql.unixAuth = true;

    users.users.postgres.extraGroups = [ "sockets" "shadow" ];

    services.postgresql = {
      enable = true;
      inherit package;
      # On first startup, it will be necessary to run the startupScript early.
      # It doesn't hurt that it'll run twice - it should be idempotent.
      initialScript = startupScript;
      authentication = ''
        local   all postgres           peer
        local   all all                pam
      '';
      settings = {
        unix_socket_directories = "/run/postgresql,/var/lib/sockets";
        unix_socket_group = "sockets";
        unix_socket_permissions = "0770";
        log_connections = true;
        logging_collector = true;
        log_disconnections = true;
        log_destination = lib.mkForce "syslog";
      };
    };
  }
  ];
}

# Note: If domain is added to /etc/hosts and resolves to 127.0.0.1
# It will break some synapse key verification thing.
{ config, lib, pkgs, domain, ... }:
let
  cfg = config.m1cr0man.matrix;

  server = "${config.networking.hostName}.${domain}";

  # Required protocol endpoints
  urlPrefix = "/.well-known/matrix";
  serverInfo = builtins.toJSON {
    "m.server" = "${server}:443";
  };
  clientInfo = builtins.toJSON {
    "m.homeserver" = { "base_url" = "https://${server}"; };
    # "m.identity_server" = { "base_url" = "https://vector.im"; };
  };

  corsAny = ''
    Header set Content-Type "application/json"
    Header set Access-Control-Allow-Origin "*"
  '';

  mkLocation = info: {
    alias = pkgs.writeText "matrix-info.json" info;
    extraConfig = corsAny;
  };

  # Client
  element = pkgs.element-web.override {
    conf.showLabsSettings = true;
    conf.default_server_config."m.homeserver" = {
      # base_url _should_ be set to domain because Element will look for .well-known/matrix/client
      # however it does not, and then fails to GET _matrix/
      "base_url" = "https://${server}";
      "server_name" = server;
    };
  };

  dbname = "matrix-synapse";
in
{
  options.m1cr0man.matrix = with lib; {
    registrationSecret = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = ''
        The registration secret for initial admin setup.
        This secret is not secure and should be removed once completed.
      '';
    };
  };

  config = {
    services.postgresql.ensureUsers = [{
      name = dbname;
      ensurePermissions = {
        "DATABASE \"${dbname}\"" = "ALL PRIVILEGES";
      };
    }];
    m1cr0man.postgresql.startupCommands = ''
      CREATE DATABASE "${dbname}" TEMPLATE template0 LC_COLLATE = "C" LC_CTYPE = "C";
    '';

    services.httpd.virtualHosts = {
      "${domain}".locations = {
        "${urlPrefix}/server" = mkLocation serverInfo;
        "${urlPrefix}/client" = mkLocation clientInfo;
      };

      "${server}" = lib.m1cr0man.makeVhost {
        documentRoot = "/var/empty";

        # Forward all Matrix API calls to the synapse Matrix homeserver
        locations."/_matrix" = {
          # proxyPass = "http://[::1]:8194/_matrix";
          # CORS headers needed to allow element.${domain} to make calls from clients
          # X-Forwarded-Proto suppresses some errors
          extraConfig = corsAny + ''
            ProxyPass http://[::1]:8194/_matrix nocanon
            ProxyPassReverse http://[::1]:8194/_matrix
            RequestHeader set X-Forwarded-Proto "https"
            ProxyPreserveHost On
          '';
        };
      };

      "element.${domain}" = lib.m1cr0man.makeVhost {
        documentRoot = element;
      };
    };

    services.matrix-synapse = {
      enable = true;
      settings = {
        server_name = domain;
        # Used for initial set up
        registration_shared_secret = lib.mkIf (cfg.registrationSecret != "") cfg.registrationSecret;
        listeners = [
          {
            port = 8194;
            bind_addresses = ["::1"];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = [ "client" "federation" ];
                compress = false;
              }
            ];
          }
        ];
        log_config = pkgs.writeText "synaps-log-config" ''
          version: 1

          # In systemd's journal, loglevel is implicitly stored, so let's omit it
          # from the message text.
          formatters:
              journal_fmt:
                  format: '%(name)s: [%(request)s] %(message)s'

          filters:
              context:
                  (): synapse.util.logcontext.LoggingContextFilter
                  request: ""

          handlers:
              journal:
                  class: systemd.journal.JournalHandler
                  formatter: journal_fmt
                  filters: [context]
                  SYSLOG_IDENTIFIER: matrix-synapse

          root:
              level: WARN
              handlers: [journal]

          disable_existing_loggers: False
        '';
      };
    };
  };
}

{ pkgs, lib, config, ... }:
let
  documentRoot = pkgs.m1cr0man.vcc-hugo;

  # Need to configure a basic nginx server to facilitate
  # the pre-proxy authentication to mailform via imhumane.
  nginxConfig = pkgs.writeText "vcc-site-nginx-config" ''
    daemon off;
    worker_processes 1;

    error_log  /var/log/vcc-site/error.log;
    pid        /var/run/vcc-site/nginx.pid;

    events {
      worker_connections  1024;
    }

    http {
      include            ${pkgs.nginx}/conf/mime.types;
      default_type       application/octet-stream;
      keepalive_timeout  15;
      sendfile           on;
      gzip               on;

      log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';
      access_log  /var/log/vcc-site/access.log main;

      upstream imhumane {
        server unix:/var/run/imhumane-rs/listener.sock;
      }

      upstream mailform {
        server unix:/var/run/mailform-rs/listener.sock;
      }

      server {
        listen           8097;
        port_in_redirect off;
        root             ${documentRoot};

        proxy_hide_header Access-Control-Allow-Origin;
        proxy_hide_header Access-Control-Allow-Method;
        proxy_hide_header Access-Control-Allow-Methods;
        proxy_hide_header Access-Control-Allow-Headers;
        proxy_hide_header Access-Control-Allow-Credentials;

        location /api/validate_token {
          internal;

          # Hack to add the query string to the request to validate the token.
          if ($request_uri ~* "[^\?]+\?(.*)$") {
            set $args $1;
          }

          rewrite ^.* /api/imhumane/v1/tokens/validate last;
          proxy_pass_request_body  off;
          proxy_set_header         Content-Length "";
        }

        location /api/imhumane/ {
          proxy_pass http://imhumane/;
        }

        location /api/mailform/ {
          auth_request /api/validate_token;
          proxy_pass http://mailform/;
        }
      }
    }
  '';
in {
  sops.secrets.mailform_env_config = {};

  # Takes precedence over Environment options in systemd unit.
  systemd.services.mailform-rs.serviceConfig.EnvironmentFile = config.sops.secrets.mailform_env_config.path;
  m1cr0man.mailform-rs = {
    enable = true;
    mailConfig = {
      smtpHost = "from_env_file";
      smtpUsername = "from_env_file";
      smtpPassword = "from_env_file";
      fromAddress = "from_env_file";
      toAddress = "from_env_file";
      fixedSubject = "A message via vccomputers.ie";
    };
  };

  m1cr0man.imhumane-rs = {
    enable = true;
    imageConfig.imagesDirectory = "/var/lib/imhumane-rs/images";
  };

  systemd.services.vcc-site = {
    wantedBy = [ "multi-user.target" ];
    before = [ "httpd.service" ];
    serviceConfig = {
      DynamicUser = true;
      SupplementaryGroups = [ "mailform" "imhumane" ];
      LogsDirectory = "vcc-site";
      RuntimeDirectory = "vcc-site";
      ExecStart = "${pkgs.nginx}/bin/nginx -c ${nginxConfig} -e /var/log/vcc-site/error.main.log";
    };
  };
}

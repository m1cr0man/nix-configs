{ config, lib, ... }:
let
  cfg = config.m1cr0man.matrix;
  domain = config.m1cr0man.domain;
  server = "${cfg.serverHostname}.${domain}";
  # port = 6167;
  socket = "/run/continuwuity/continuwuity.sock";
  svcUrl = "unix:${socket}|http://localhost/";
in
{
  options.m1cr0man.matrix = with lib; {
    # registrationSecret = mkOption {
    #   default = null;
    #   type = types.nullOr types.str;
    #   description = ''
    #     The registration secret for initial admin setup.
    #     This secret is not secure and should be removed once completed.
    #   '';
    # };
    serverHostname = mkOption {
      default = "matrix";
      type = types.str;
      description = ''
        Hostname of the publically accessible address of the server.
      '';
    };
  };

  config.services.matrix-continuwuity = {
    enable = true;
    settings = {
      global = {
        server_name = domain;
        # address = [ "::1" ];
        # port = [ port ];
        unix_socket_path = socket;

        well_known = {
          server = "${server}:443";
          client = "https://${server}";
        };

        url_preview_domain_contains_allowlist = [
          "docs.rs"
          "facebook.com"
          "freedesktop.org"
          "github.com"
          "gitlab.com"
          "gnome.org"
          "instagram.com"
          "kde.org"
          "kernel.org"
          "lix.systems"
          "matrix.to"
          "mozilla.org"
          "nixos.org"
          "wikipedia.org"
          "youtu.be"
          "youtube.com"
        ];
        url_preview_check_root_domain = true;
      };
    };
  };

  config.users.users.wwwrun.extraGroups = [ "continuwuity" ];

  config.services.httpd.virtualHosts = {
    "${domain}".locations."/.well-known/matrix".proxyPass = "${svcUrl}.well-known/matrix";

    "${server}" = lib.m1cr0man.makeVhost {
      documentRoot = "/var/empty";

      # Forward all Matrix API calls to the synapse Matrix homeserver
      locations."/".extraConfig = ''
        ProxyPass ${svcUrl} nocanon
        ProxyPassReverse ${svcUrl}
        RequestHeader set X-Forwarded-Proto "https"
        ProxyPreserveHost On
      '';
    };
  };
}

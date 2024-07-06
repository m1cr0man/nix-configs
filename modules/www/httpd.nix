# TODO Allow telegraf to read logs
{ config, lib, domain, ... }:
let
  cfg = config.m1cr0man.webserver;

  user = config.services.httpd.user;
in
{
  options.m1cr0man.webserver = with lib; {
    htpasswdSecret = mkOption {
      type = types.str;
      default = "generic_htpasswd";
      description = "SOPS secret key for htpasswd to use for /.server-status auth.";
    };
    setupACME = lib.mkOption {
      default = true;
      example = true;
      description = "Whether to enable ACME provisioning.";
      type = lib.types.bool;
    };
  };

  config = lib.mkMerge [
    {
      services.httpd = {
        enable = true;
        mpm = "event";
        maxClients = 500;
        logFormat = "combinedplus";
        extraModules = [ "proxy_wstunnel" ];

        extraConfig = ''
          LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %v" combinedplus
          ProxyPreserveHost On
          DirectoryIndex index.php index.html index.htm index.shtml
        '';

        # Vhost for server status
        virtualHosts."127.0.0.1" = {
          extraConfig = ''
            <Location "/.server-status">
              SetHandler server-status
              <RequireAny>
                Require ip 127.0.0.1
              </RequireAny>
            </Location>
          '';
        };

        adminAddr = config.m1cr0man.adminEmail;

        # Only acme certs and status are accessible via port 80,
        # everything else is explicitly upgraded to https
      };

      services.telegraf.extraConfig.inputs.apache = {
        urls = [ "http://127.0.0.1/.server-status?auto" ];
      };

      networking.firewall.allowedTCPPorts = [ 80 443 ];
    }

    (lib.mkIf cfg.setupACME {
      users.users."${user}".extraGroups = [ "acme" ];
    })

    # Set up sops secrets
    (lib.m1cr0man.setupSopsSecret { inherit user; name = cfg.htpasswdSecret; })
  ];
}

{ domain, config, lib, pkgs, ... }:
let
  inherit (lib.m1cr0man) makeVhost makeVhostProxy makeLocationProxy;
in
{
  # Route local connections locally
  # networking.hosts."::1" = builtins.concatLists (
  #   lib.mapAttrsToList
  #     (domain: vhost: [ domain ] ++ vhost.serverAliases)
  #     config.services.httpd.virtualHosts
  # );

  m1cr0man.monitoring.logFiles = [
    "/var/log/httpd/*.log"
  ];

  systemd.services.vector.serviceConfig.SupplementaryGroups = lib.mkForce [
    "wwwrun"
    "systemd-journal"
  ];

  systemd.services.httpd.serviceConfig = {
    LogsDirectory = "httpd";
    LogsDirectoryMode = 0755;
  };

  services.httpd.virtualHosts = {

    "${domain}" = makeVhost {
      serverAliases = [ "www.${domain}" ];
      documentRoot = pkgs.m1cr0man.m1cr0blog;
    };

    "dav.${domain}" = makeVhost {
      extraConfig = ''
        Redirect 301 /card https://carddav.${domain}
        Redirect 301 /.well-known/carddav https://carddav.${domain}
      '';
    };

    "carddav.${domain}" = makeVhostProxy {
      host = "email:5232";
    };

    "headscale.${domain}" = lib.mkIf (config.services.headscale.enable) (makeVhost {
      extraConfig = ''
        ProxyPreserveHost On
        ProxyPass / http://localhost:${builtins.toString config.services.headscale.port}/ upgrade=any
      '';
    });

    "breogan.${domain}" = makeVhostProxy { host = "containerhost.local:1357"; };

    "eggnor.${domain}" = makeVhostProxy { host = "containerhost.local:5120"; };

    # Subdomain can't use wildcard certs
    # Also, socket.io doesn't like the RewriteRule style websocket handling
    "foundry-conor.${domain}" = makeVhost {
      extraConfig = ''
        ProxyPreserveHost On
        ProxyPass  "/socket.io/" "ws://containerhost.local:30000/socket.io/"
        ProxyPass / http://containerhost.local:30000/
        ProxyPassReverse / http://containerhost.local:30000/
      '';
    };

    "foundry-anders.${domain}" = makeVhost {
      extraConfig = ''
        ProxyPreserveHost On
        ProxyPass  "/socket.io/" "ws://containerhost.local:30001/socket.io/"
        ProxyPass / http://containerhost.local:30001/
        ProxyPassReverse / http://containerhost.local:30001/
      '';
    };

    "foundry-patrick.${domain}" = makeVhost {
      extraConfig = ''
        ProxyPreserveHost On
        ProxyPass  "/socket.io/" "ws://containerhost.local:30002/socket.io/"
        ProxyPass / http://containerhost.local:30002/
        ProxyPassReverse / http://containerhost.local:30002/
      '';
    };

    "mail.vccomputers.ie" = makeVhost {
      forceSSL = false;
      addSSL = false;
      useACMEHost = null;
      extraConfig = ''
        Redirect 301 / https://mail.${domain}
      '';
    };

    "julia-mendez.com" = makeVhost {
      useACMEHost = null;
      enableACME = true;
      serverAliases = [ "www.julia-mendez.com" ];
      documentRoot = "/var/lib/julia";
      extraConfig = ''
        RewriteEngine on
        RewriteCond %{HTTP_HOST} ^www\.julia-mendez.com$ [NC]
        RewriteRule ^(.*)$ http://julia-mendez.com/$1 [R=301,L]
      '';
    };
  };
}

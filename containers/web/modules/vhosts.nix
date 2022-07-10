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

  security.acme.certs."foundry.conor.${domain}".reloadServices = [ "httpd.service" ];

  services.httpd.enablePHP = true;
  services.httpd.phpOptions = ''
    upload_max_filesize = 50M
    post_max_size = 50M
    error_reporting = E_ALL ^ (E_NOTICE | E_WARNING | E_DEPRECATED)
  '';
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
      host = "containerhost.local:5232";
    };

    "mail.${domain}" = makeVhost {
      documentRoot = pkgs.rainloop-community;
    };

    "breogan.${domain}" = makeVhostProxy { host = "containerhost.local:1357"; };

    "eggnor.${domain}" = makeVhostProxy { host = "containerhost.local:5120"; };

    # Subdomain can't use wildcard certs
    "foundry.conor.${domain}" = (makeVhostProxy { host = "containerhost.local:30000"; }) // {
      useACMEHost = null;
      enableACME = true;
    };

    "mail.vccomputers.ie" = makeVhost {
      forceSSL = false;
      addSSL = false;
      useACMEHost = null;
      extraConfig = ''
        Redirect 301 / https://mail.${domain}
      '';
    };
  };
}

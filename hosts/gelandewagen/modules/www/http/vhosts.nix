{ domain, lib, pkgs, ... }:
with lib.m1cr0man;
{
  services.httpd.virtualHosts = {

    "m1cr0man.com" = makeVhost {
      serverAliases = [ "www.m1cr0man.com" ];
      documentRoot = pkgs.m1cr0man.m1cr0blog;
    };

    "breogan.${domain}" = makeVhostProxy { host = "127.0.0.1:1357"; };

    "eggnor.m1cr0man.com" = makeVhostProxy { host = "127.0.0.1:5120"; };

    # Subdomain can't use wildcard certs
    "foundry.conor.${domain}" = (makeVhostProxy { host = "127.0.0.1:30000"; }) // {
      useACMEHost = null;
      enableACME = true;
    };

  };

  security.acme.certs."foundry.conor.${domain}".reloadServices = [ "httpd.service" ];
}

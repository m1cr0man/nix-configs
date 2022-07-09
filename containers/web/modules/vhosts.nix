{ domain, config, lib, pkgs, ... }:
let
  inherit (lib.m1cr0man) makeVhost makeVhostProxy;
in
{
  services.httpd.virtualHosts = {

    "${domain}" = makeVhost {
      serverAliases = [ "www.${domain}" ];
      documentRoot = pkgs.m1cr0man.m1cr0blog;
    };

    "breogan.${domain}" = makeVhostProxy { host = "containerhost.local:1357"; };

    "eggnor.${domain}" = makeVhostProxy { host = "containerhost.local:5120"; };

    # Subdomain can't use wildcard certs
    "foundry.conor.${domain}" = (makeVhostProxy { host = "containerhost.local:30000"; }) // {
      useACMEHost = null;
      enableACME = true;
    };
  };

  security.acme.certs."foundry.conor.${domain}".reloadServices = [ "httpd.service" ];
}

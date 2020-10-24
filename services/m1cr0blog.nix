{ pkgs, ... }:
let
    m1cr0blog = import ../packages/m1cr0blog { inherit pkgs; };
in {
  services.httpd.virtualHosts."m1cr0man.com" = {
    forceSSL = true;
    enableACME = true;
    serverAliases = [ "www.m1cr0man.com" ];
    documentRoot = m1cr0blog;
  };

  security.acme.certs."m1cr0man.com".extraDomainNames = [ "www.m1cr0man.com" ];
}

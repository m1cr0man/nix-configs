{ config, ... }:
let
  cfg = config.m1cr0man.acme;
in
{
  # Add a wildcard cert for m1cr0test
  security.acme.certs."m1cr0test.tk" = {
    domain = "*.m1cr0test.tk";
    extraDomainNames = [ "m1cr0test.tk" ];
    dnsProvider = "rfc2136";
    credentialsFile = config.sops.secrets."${cfg.rfc2136EnvSecret}".path;
    dnsPropagationCheck = true;
    reloadServices = [ "httpd.service" ];
  };
}

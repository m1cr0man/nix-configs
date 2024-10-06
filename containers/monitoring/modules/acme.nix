{ config, domain, ... }:
let
  dnsCfg = {
    dnsProvider = "cloudflare";
    credentialsFile = config.sops.secrets.acme_cloudflare_env.path;
    dnsPropagationCheck = true;
  };

  mkCert = dom: dnsCfg // {
    domain = "*.${dom}";
    extraDomainNames = [ dom ];
    reloadServices = [ "httpd.service" ];
  };
in
{
  security.acme = {
    certs."int.${domain}" = mkCert "int.${domain}";
  };
}

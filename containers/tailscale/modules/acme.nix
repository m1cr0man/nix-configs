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
    certs."ts.${domain}" = mkCert "ts.${domain}";
  };
}

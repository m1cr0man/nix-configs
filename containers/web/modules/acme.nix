{ config, ... }:
let
  btt = "blamethe.tools";
  m1 = "m1cr0man.com";

  dnsCfg = {
    dnsProvider = "cloudflare";
    credentialsFile = config.sops.secrets.acme_cloudflare_env.path;
    dnsPropagationCheck = true;
  };

  mkCert = domain: dnsCfg // {
    domain = "*.${domain}";
    extraDomainNames = [ domain ];
  };
in
{
  security.acme = {
    certs."${btt}" = mkCert btt;
    certs."${m1}" = mkCert m1;
    certs."unimog.m1cr0man.com" = dnsCfg;
  };
}

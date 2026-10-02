{ config, ... }:
let
  m1 = "m1cr0man.com";

  dnsCfg = {
    dnsProvider = "cloudflare";
    environmentFile = config.sops.secrets.acme_cloudflare_env.path;
    dnsPropagationCheck = true;
  };

  mkCert = domain: dnsCfg // {
    domain = "*.${domain}";
    extraDomainNames = [ domain ];
  };
in
{
  security.acme = {
    certs."${m1}" = mkCert m1;
    certs."unimog.m1cr0man.com" = dnsCfg;
  };
}

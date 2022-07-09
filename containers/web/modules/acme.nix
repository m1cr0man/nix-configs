{ config, ... }:
let
  btt = "blamethe.tools";
  m1 = "m1cr0man.com";

  mkCert = domain: {
    domain = "*.${domain}";
    extraDomainNames = [ domain ];
    dnsProvider = "cloudflare";
    credentialsFile = config.sops.secrets.acme_cloudflare_env.path;
    dnsPropagationCheck = true;
  };
in
{
  security.acme = {
    certs."${btt}" = mkCert btt;
    certs."${m1}" = mkCert m1;
  };
}

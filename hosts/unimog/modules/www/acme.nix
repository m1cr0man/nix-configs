{ config, ... }:
let
  btt = "blamethe.tools";

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
    acceptTerms = true;
    defaults = {
      email = config.m1cr0man.adminEmail;
      # Enable when doing dev work
      # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    };

    certs."${btt}" = mkCert btt;
  };
}

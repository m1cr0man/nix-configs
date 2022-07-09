{ domain, config, ... }:
let
  ms = config.mailserver;
in
{
  security.acme.certs."${ms.fqdn}" = {
    extraDomainNames = [
      "${ms.sendingFqdn}"
    ];
    dnsProvider = "cloudflare";
    credentialsFile = config.sops.secrets.acme_cloudflare_env.path;
    dnsPropagationCheck = true;
    reloadServices = [ "postfix.service" "dovecot2.service" ];
  };
}

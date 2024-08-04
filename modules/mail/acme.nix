{ config, ... }:
let
  cfg = config.m1cr0man.mailserver;
in
{
  security.acme.certs."${cfg.fqdn}" = {
    extraDomainNames = [
      "${cfg.sendingFqdn}"
    ];
    dnsProvider = "cloudflare";
    credentialsFile = config.sops.secrets.acme_cloudflare_env.path;
    dnsPropagationCheck = true;
    reloadServices = [ "postfix.service" "dovecot2.service" ];
  };
}

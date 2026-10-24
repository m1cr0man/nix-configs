{ config, ... }:
let
  cfg = config.m1cr0man.mailserver;
in
{
  security.acme.certs."${cfg.fqdn}" = {
    extraDomainNames = [
      "${cfg.sendingFqdn}"
    ];
    dnsResolver = "1.1.1.1:53";
    dnsProvider = "cloudflare";
    environmentFile = config.sops.secrets.acme_cloudflare_env.path;
    dnsPropagationCheck = true;
    reloadServices = [ "postfix.service" "dovecot.service" ];
  };

  users.users.dovecot2.extraGroups = [ "acme" ];
  users.users.postfix.extraGroups = [ "acme" ];
}

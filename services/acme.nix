{ config, lib, ... }:
{
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "lucas+acme@m1cr0man.com";
  # security.acme.defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";

  users.users.wwwrun.extraGroups = [ "acme" ];
  security.acme.certs."m1cr0man.com".group = "acme";

  systemd.services = let
    dependency = ["bind.service"];
  in lib.mapAttrs' (name: _: lib.nameValuePair "acme-${name}" {
    requires = dependency;
    after = dependency;
  }) config.security.acme.certs;
}

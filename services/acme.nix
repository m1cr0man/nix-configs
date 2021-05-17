{
  security.acme.acceptTerms = true;
  security.acme.email = "lucas+acme@m1cr0man.com";
  # security.acme.server = "https://acme-staging-v02.api.letsencrypt.org/directory";

  users.users.wwwrun.extraGroups = [ "acme" ];
  security.acme.certs."m1cr0man.com".group = "acme";
}

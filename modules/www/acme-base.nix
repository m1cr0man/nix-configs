{ config, ... }:
{
  users.users.acme.uid = 999;
  users.groups.acme.gid = 994;

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = config.m1cr0man.adminEmail;
      # Enable when doing dev work
      # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    };
  };
}

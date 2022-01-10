{ config, lib, domain, ... }:
let
  cfg = config.m1cr0man.acme;
in
{
  options.m1cr0man.acme = with lib; {
    rfc2136EnvSecret = mkOption {
      type = types.str;
      default = "acme_rfc2136_env";
      description = ''
        SOPS secret with environment variables for RFC2136
        cert validation.
      '';
    };
  };

  config = {
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = config.m1cr0man.adminEmail;
        # Enable when doing dev work
        # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      };

      certs."${domain}" = {
        domain = "*.${domain}";
        extraDomainNames = [ domain ];
        dnsProvider = "rfc2136";
        credentialsFile = config.sops.secrets."${cfg.rfc2136EnvSecret}".path;
        dnsPropagationCheck = true;
      };
    };

    # Make all ACME units wait for the DNS server to start
    systemd.services =
      let
        dependency = [ "bind.service" ];
      in
      lib.mapAttrs'
        (name: _: lib.nameValuePair "acme-${name}" {
          requires = dependency;
          after = dependency;
        })
        config.security.acme.certs;
  }

  # Set up sops secrets
  # Note cannot refer to config.users.users.acme.name here since that section
  # of config depends on the data above, which in turn causes infinite recursion
  // (lib.m1cr0man.setupSopsSecret { user = "acme"; name = cfg.rfc2136EnvSecret; });
}

# TODO monitoring
{ config, lib, ... }:
let
  cfg = config.m1cr0man.dnsserver;

  user = "named";
in
{
  options.m1cr0man.dnsserver = with lib; {
    dnskeysSecret = mkOption {
      type = types.str;
      default = "bind_dnskeys_conf";
      description = ''
        SOPS secret key for TSIG config/dynamic updates.
        Generate with tsig-keygen rfc2136.key.m1cr0man.com. > key.conf
      '';
    };
  };

  config = {
    services.bind = {
      enable = true;

      cacheNetworks = [
        # Localhost
        "127.0.0.0/24"
        # Docker
        "172.17.0.0/16"
        # NixOS Containers
        "10.233.0.0/16"
      ];

      # Load the TSIG key for dynamic updates
      extraConfig = ''
        include "${config.sops.secrets."${cfg.dnskeysSecret}".path}";
      '';
    };

    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];
  }

  # Set up sops secrets
  // (lib.m1cr0man.setupSopsSecret { inherit user; name = cfg.dnskeysSecret; });
}

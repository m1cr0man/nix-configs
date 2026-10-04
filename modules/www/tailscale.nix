{ pkgs, config, lib, ... }:
let
  cfg = config.m1cr0man.tailscale;
in
{
  options.m1cr0man.tailscale = {
    preferLocalSubnets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "192.168.1.0/24" "fd00:abcd::/64" ];
      description = ''
        Subnets which should prefer the directly-attached route over a
        Tailscale subnet router. Installs an ip rule per subnet at a
        priority below Tailscale's (~5230) that forces lookup of the
        main routing table first.
      '';
    };
  };

  config = {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "both";
    };

    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    environment.systemPackages = [ pkgs.tailscale ];

    # Fix the ping command
    systemd.services.tailscaled.path = [ pkgs.iputils ];

    systemd.network.networks = lib.mkIf (cfg.preferLocalSubnets != [ ]) {
      "10-tailscale-prefer-local" = {
        matchConfig.Name = "lo";
        routingPolicyRules = map (subnet: {
          To = subnet;
          Table = "main";
          Priority = 5000;
        }) cfg.preferLocalSubnets;
      };
    };
  };
}

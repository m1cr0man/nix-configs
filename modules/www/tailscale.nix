{ pkgs, config, lib, ... }:
let
  cfg = config.m1cr0man.tailscale;
in
{
  options.m1cr0man.tailscale = {
    enableLocalRoutingPatch = lib.mkEnableOption "the routing patch which allows local routes to take priority over TS subnet routes";
  };

  config = {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "both";
      # More info: https://github.com/tailscale/tailscale/issues/1227#issuecomment-2094494048
      package = lib.mkIf (cfg.enableLocalRoutingPatch) (pkgs.tailscale.overrideAttrs (prevAttrs: {
        patches = prevAttrs.patches or [ ] ++ [
          (pkgs.fetchpatch2 {
            url = "https://github.com/m1cr0man/tailscale/commit/3c1e37ff176408b33603158820ba00e9a4d30f2a.patch";
            hash = "sha256-BmjWkU93URwCHbpj5hBAXqIiOvJTuwrYDKxsffgVzV8=";
          })
        ];
      }));
    };

    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    environment.systemPackages = [ pkgs.tailscale ];

    # Fix the ping command
    systemd.services.tailscaled.path = [ pkgs.iputils ];
  };
}

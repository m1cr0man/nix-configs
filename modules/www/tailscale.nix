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
            url = "https://github.com/Atemu/tailscale/commit/bbce05e450ec10de80ff16125d5d8428f76ceb3b.patch";
            hash = "sha256-S71VtEIQ9d4vbOqXJ68w3HN2M/60BCBtK2uWHXVtDqQ=";
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

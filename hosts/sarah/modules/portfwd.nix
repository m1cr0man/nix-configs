{ pkgs, ... }:
{
  systemd.services.portfwd-mc = {
    description = "Forwards MC port to phoenix";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "tailscale.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:25565,fork,reuseaddr TCP:phoenix.george.ts.m1cr0man.com:25565";
      Restart = "always";
      RestartSec = 10;
    };
  };
}

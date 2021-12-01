{ pkgs, ... }:
{
  users.users.openttd = {
    description = "Service user for openttd";
    isSystemUser = true;
    shell = "/dev/null";
    home = "/dev/null";
    group = "openttd";
  };
  users.groups.openttd = {};

  systemd.services.openttd = {
    description = "Transport tycoon game";
    requires = [ "var-gaming.mount" ];
    after = [ "network.target" "var-gaming.mount" ];
    wantedBy = [ "multi-user.target" ];

    environment = { NODE_ENV = "production"; };

    script = ''
      ${pkgs.openttd}/bin/openttd -D
    '';

    serviceConfig = {
        User = "openttd";
        Restart = "always";
        WorkingDirectory = "/var/gaming/openttd-ddafm";
    };
  };

  networking.firewall.allowedTCPPorts = [ 3979 ];
  networking.firewall.allowedUDPPorts = [ 3979 ];
}

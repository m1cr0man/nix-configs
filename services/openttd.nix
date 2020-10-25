{ pkgs, ... }:
{
  users.users.openttd = {
    description = "Service user for openttd";
    isSystemUser = true;
    shell = "/dev/null";
    home = "/dev/null";
  };

  systemd.services.openttd = {
    description = "Transport tycoon game";
    after = [ "network.target" "zfs-import.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = { NODE_ENV = "production"; };

    script = ''
      ${pkgs.openttd}/bin/openttd -D
    '';

    serviceConfig = {
        User = "openttd";
        Restart = "always";
        WorkingDirectory = "/opt/generic/openttd-ddafm";
    };
  };

  networking.firewall.allowedTCPPorts = [ 3979 ];
  networking.firewall.allowedUDPPorts = [ 3979 ];
}

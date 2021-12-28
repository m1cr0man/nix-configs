{ pkgs, config, ... }:
with import ../lib/polkit-helpers.nix;
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
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      MemoryMax = "1G";
      UMask = "0002";
      User = "openttd";
      Group = "openttd";
      Restart = "always";
      StateDirectory = "gaming/openttd";
      WorkingDirectory = "/var/lib/gaming/openttd";
      ExecStart = "${pkgs.openttd}/bin/openttd -D";
    };
  };

  security.polkit.extraConfig = makeUnitRule {
    group = "openttd";
    unit = "openttd.service";
  };

  networking.firewall.allowedTCPPorts = [ 3979 ];
  networking.firewall.allowedUDPPorts = [ 3979 ];
}

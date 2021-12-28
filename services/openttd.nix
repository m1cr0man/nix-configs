{ pkgs, config, ... }:
with import ../lib/polkit-helpers.nix;
let
  openttd = pkgs.openttd.overrideAttrs (oldAttrs: {
    version = "20211222";

    src = pkgs.fetchurl {
      url = "https://cdn.openttd.org/openttd-nightlies/2021/20211222-master-ga97bce51c2/openttd-20211222-master-ga97bce51c2-source.tar.xz";
      sha256 = "e2c4ee9c7fffa94bc5f07c8bbd7eb0d5d01b0c76db38d3882722bf79c6708eb6";
    };
  });
in {
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
      ExecStart = "${openttd}/bin/openttd -D";
    };
  };

  security.polkit.extraConfig = makeUnitRule {
    group = "openttd";
    unit = "openttd.service";
  };

  networking.firewall.allowedTCPPorts = [ 3979 ];
  networking.firewall.allowedUDPPorts = [ 3979 ];
}

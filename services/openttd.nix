{ pkgs, ... }:
let
  openttd = pkgs.openttd.overrideAttrs (old: {
    src = pkgs.fetchurl {
      url = "https://cdn.openttd.org/openttd-releases/1.10.1/openttd-1.10.1-source.tar.xz";
      sha256 = "0d22a3c50f7a321f4f211594f4987ac16c381e8e3e40f116848e63e91e7fbb9b";
    };
  });
in {
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
      ${openttd}/bin/openttd -D
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

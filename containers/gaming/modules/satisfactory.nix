{ pkgs, ... }: let
  installdir = "/var/lib/gaming/satisfactory";
in {
  users.users.satisfactory = {
    isSystemUser = true;
    group = "satisfactory";
    home = installdir;
  };
  users.groups.satisfactory = {};

  networking.firewall.allowedUDPPorts = [ 7777 8888 ];
  networking.firewall.allowedTCPPorts = [ 7777 8888 ];

  systemd.services.satisfactory = {
    description = "Satisfactory Dedicated Server";
    wants = [ "network.target" ];
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      WorkingDirectory = installdir;
      ExecStartPre = "+${pkgs.coreutils}/bin/chown -R satisfactory:satisfactory ${installdir}";
      ExecStart = "${pkgs.steam-run}/bin/steam-run ${installdir}/FactoryServer.sh";
      Restart = "always";
      RestartSec = "10";
      User = "satisfactory";
      Group = "satisfactory";
    };
  };
}

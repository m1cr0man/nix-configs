{ pkgs, ... }:
let
  identityFile = "/var/lib/rb-tunnel/id_ed25519";
in {
  users.users.rb-tunnel = {
    description = "Service user for Redbrick tunnel";
    isSystemUser = true;
    shell = "/dev/false";
    home = "/var/empty";
  };

  systemd.services.rb-tunnel = {
    description = "Redbrick tunnel";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
        ExecStart = ''
          ${pkgs.openssh}/bin/ssh -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' \
          -i ${identityFile} -vNL 7764:irc.redbrick.dcu.ie:6667 m1cr0man@redbrick.dcu.ie
        '';
        User = "rb-tunnel";
        Restart = "always";
        RestartSec = "10";
        WorkingDirectory = "/var/empty";
    };
  };

}

{ pkgs, ... }:
let
  unlocker = "${pkgs.m1cr0man.scripts}/bin/zfs-unlocker";
  passwordFile = "/var/secrets/unlocker_password.txt";
  identityFile = "/root/.ssh/id_ed25519";
in
{
  systemd.services.unlocker = {
    description = "Encrypted ZFS root unlocker";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ openssh ];

    serviceConfig = {
      ExecStart = ''
        ${unlocker} ${passwordFile} ${identityFile}
      '';
      Restart = "always";
      RestartSec = "10";
      WorkingDirectory = "/var/empty";
    };
  };
}

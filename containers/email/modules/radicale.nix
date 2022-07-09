{ config, pkgs, lib, ... }:
let
  inherit (lib) mapAttrsToList;
  inherit (builtins) concatStringsSep;

  mailAccounts = config.mailserver.loginAccounts;
  secretPaths = mapAttrsToList (mail: user: "${mail}\n${user.hashedPasswordFile}") mailAccounts;
  secrets = concatStringsSep "\n" secretPaths;

  # Will be written in the service's WorkingDirectory
  passwdFile = "radicale.users";
  htpasswdGenerateScript = pkgs.writeShellScript "radicale-htpasswd-generate" ''
    echo -n "" > ${passwdFile}
    chmod 400 ${passwdFile}
    chown radicale:radicale ${passwdFile}
    while read mail && read secret_path; do
      echo -n "''${mail}:" >> ${passwdFile}
      cat "$secret_path" >> ${passwdFile}
      echo >> ${passwdFile}
    done << EOF
    ${secrets}
    EOF
  '';

  stateDir = config.m1cr0man.container.stateDir;
  port = 5232;
  portStr = builtins.toString port;
in
{
  networking.firewall.allowedTCPPorts = [ port ];

  # + prefix means run as root
  systemd.services.radicale.serviceConfig.ExecStartPre = "+${htpasswdGenerateScript}";

  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = [ "0.0.0.0:${portStr}" "[::]:${portStr}" ];
      };
      storage = {
        filesystem_folder = "${stateDir}/radicale";
      };
      auth = {
        type = "htpasswd";
        htpasswd_filename = passwdFile;
        htpasswd_encryption = "bcrypt";
      };
    };
  };
}

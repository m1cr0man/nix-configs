{ pkgs, config, lib, ... }:
{
  imports = [
    ./base.nix
    ./zfs.nix
    ./commands.nix
  ];

  # Use DHCP during the initrd, then undo the config before stage 2 boot
  boot.initrd.postMountCommands = ''
    ip a flush eth0
    ip l set eth0 down
  '';

  # Fix vscode-server node binary on login
  environment.shellInit = let
    node = pkgs.nodejs-14_x;
    findutils = pkgs.findutils;
  in ''
    umask 0027
    if test -e ~/.vscode-server; then
      ${findutils}/bin/find ~/.vscode-server -type f -name node \( -execdir rm '{}' \; -and -execdir ln -s '${node}/bin/node' '{}' \; \)
    fi
  '';

  # Enable rsyslog
  services.rsyslogd.enable = true;
  services.rsyslogd.extraConfig = "*.* @127.0.0.1:6514;RSYSLOG_SyslogProtocol23Format";

  # Rotate logs with cron
  services.cron.enable = true;
  services.cron.systemCronJobs = [
    "0 4 * * * journalctl --vacuum-time=7d"
  ];
}

{ config, pkgs, lib, ... }:
let
  cfg = config.m1cr0man.mailserver;
  d2 = config.services.dovecot2;
  pkg = d2.package;
  remoteHost = cfg.replicationPeer;
in
lib.mkIf (remoteHost != null) {
  systemd.services.dovecot-sync = {
    description = "Periodic Dovecot Mailbox Synchronization";

    serviceConfig = {
      Type = "oneshot";
      # User = "dovecot2";
      # Group = "dovecot2";
      User = d2.settings.mail_uid;
      Group = d2.settings.mail_gid;
      SupplementaryGroups = "dovecot2";
      # NoNewPrivileges = false;
      # AmbientCapabilities = "CAP_SETUID CAP_SETGID CAP_DAC_OVERRIDE";
      ExecStart = "${pkg}/bin/doveadm -D sync -A -N -l 30 -x 'virtual/*' 'tcp:${remoteHost}:${builtins.toString cfg.doveadmPort}'";
    };
  };

  systemd.timers.dovecot-sync = {
    description = "Timer for Dovecot Mailbox Synchronization";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = "1m";
      Persistent = true;
    };
  };
}

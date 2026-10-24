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
    after = [ "network.target" "dovecot2.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "dovecot2";
      Group = "dovecot2";
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

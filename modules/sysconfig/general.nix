{ lib, config, ... }:
let
  cfg = config.m1cr0man.general;
in
{
  options.m1cr0man.general = with lib; {
    maxJournalSize = mkOption {
      type = types.str;
      default = "2G";
      description = ''
        Maximum size for persistent journald logs.
        See https://www.freedesktop.org/software/systemd/man/journald.conf.html#SystemMaxUse=
      '';
    };
    maxJournalAge = mkOption {
      type = types.str;
      default = "7day";
      description = ''
        Maximum age for persistent journald logs.
        See https://www.freedesktop.org/software/systemd/man/journald.conf.html#MaxRetentionSec=
      '';
    };
    rsyslogServer = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "IP address and port of syslog server to use";
    };
  };

  config = {
    boot.kernelParams = [
      # Give me a shell if shit hits the fan
      "boot.shell_on_fail"
      # Reboot the machine upon fatal boot issues
      "boot.panic_on_fail"
      "panic=60"
    ];

    # Enable accounting so systemd-cgtop can show IO load
    systemd.enableCgroupAccounting = true;

    # Limit logs sizes and retention duration in journalctl
    # RuntimeKeepFree is used to ensure a certain amount of available mem
    # on low memory systems (< 500M)
    services.journald.extraConfig = ''
      SystemMaxUse=${cfg.maxJournalSize}
      RuntimeMaxUse=500M
      RuntimeKeepFree=250M
      MaxRetentionSec=${cfg.maxJournalAge}
    '';

    services.rsyslogd = lib.mkIf (cfg.rsyslogServer != null) {
      # Automatically enables services.journald.forwardToSyslog
      enable = true;
      extraConfig = "*.* @${cfg.rsyslogServer};RSYSLOG_SyslogProtocol23Format";
    };

    # Use SSH host key as SOPS key
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # Clean up nix store automatically
    nix.gc.automatic = true;
  };
}

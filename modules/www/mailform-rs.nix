{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.m1cr0man.mailform-rs;

  description = "Mailform contact form processor";

  coreEnvironment = lib.mapAttrs'
    (k: v: {
      value = builtins.toString v;
      name = "MAILFORM_" + (lib.m1cr0man.lowerCamelToScreamingSnake k);
    })
    (cfg.mailConfig // {
      inherit (cfg) listenerAddress;
    });

  listenerEnvironment = lib.mapAttrs'
    (k: v: {
      value = builtins.toString v;
      name = "MAILFORM_LISTENER_" + (lib.strings.toUpper k);
    })
    (cfg.extraListenerOptions);

  environment = coreEnvironment // listenerEnvironment // {
    RUST_LOG = cfg.logLevel;
    RUST_LOG_STYLE = "SYSTEMD";
  };

in {
  options.m1cr0man.mailform-rs = {
    enable = mkEnableOption description;

    mailConfig = {
      smtpHost = mkOption {
        type = types.str;
        description = "Sending mail server hostname. Must match its TLS certificate.";
      };
      smtpUsername = mkOption {
        type = types.str;
        description = "Sending mail server login username.";
      };
      smtpPassword = mkOption {
        type = types.str;
        description = "Sending mail server login password.";
      };
      fromAddress = mkOption {
        type = types.str;
        description = "Address to use in the from field of sent email.";
      };
      toAddress = mkOption {
        type = types.str;
        description = "Address to send mail to.";
      };
      sendRetries = mkOption {
        type = types.numbers.positive;
        default = 5;
        description = "Maximum times to retry sending a mail. After this, the mail will be discarded.";
      };
      fixedSubject = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "A fixed subject line to set on mails. Any subject set in requests will be discared.";
      };
    };

    listenerAddress = mkOption {
      type = types.str;
      default = "./listener.sock";
      description = "Any listening address supported by tokio_listener. See https://docs.rs/tokio-listener/latest/tokio_listener/struct.UserOptions.html";
    };

    logLevel = mkOption {
      type = types.enum [ "error" "warn" "info" "debug" "trace" ];
      default = "info";
      description = "Log level of the service";
    };

    extraListenerOptions = mkOption {
      type = types.attrs;
      default = {
        unix_listen_unlink = true;
      };
      description = "UserOptions to pass to tokio_listener. See https://docs.rs/tokio-listener/latest/tokio_listener/struct.UserOptions.html";
    };
  };

  config = {
    users.groups.mailform = {};

    users.users.mailform = {
      inherit description;
      group = "mailform";
      home = "/var/empty";
      createHome = false;
      isSystemUser = true;
      isNormalUser = false;
      useDefaultShell = false;
    };

    systemd.services.mailform-rs = {
      inherit description environment;
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        User = "mailform";
        Group = "mailform";
        UMask = "0002";
        NoNewPrivileges = true;
        ExecStart = "${pkgs.mailform-rs}/bin/mailform-rs";
        RuntimeDirectory = "mailform-rs";
        WorkingDirectory = "%t/mailform-rs";
        Restart = "always";
        RestartSec = 10;
      };
    };
  };
}

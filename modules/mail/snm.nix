{ config, lib, ... }:
let
  cfg = config.m1cr0man.mailserver;
  inherit (cfg) stateDir;

  userSopsKey = email: let
    name = builtins.head (builtins.split "@" email);
  in "${name}_hashed_password";

  accounts = lib.mapAttrs (k: v: v // {
    # Generate with nix shell nixpkgs#apacheHttpd; htpasswd -nB ""
    hashedPasswordFile = config.sops.secrets."${userSopsKey k}".path;
  }) cfg.loginAccounts;

  doveadmPasswordFile = config.sops.secrets.doveadm_password.path;
  vmailUser = config.mailserver.vmailUserName;

  certPath = config.security.acme.certs."${config.mailserver.fqdn}".directory;
in
{
  assertions = [{
    assertion = builtins.all (v: !(lib.hasAttr "loginAccounts" v)) (builtins.attrValues cfg.loginAccounts);
    message = ''
      hashedPasswordFile specified for m1cr0man.mailserver.loginAccounts.*
      will be overridden. Please remove it.
    '';
  }];

  sops.secrets = lib.mkMerge [
    (
      lib.mapAttrs'
      (k: v:
        lib.nameValuePair (userSopsKey k) {
          neededForUsers = true;
        }
      )
      cfg.loginAccounts
    )
    {
      doveadm_password.owner = config.services.dovecot2.settings.mail_uid;
    }
  ];

  users.users.virtualMail.extraGroups = [ "acme" ];

  # Fix clamav state directory
  users.users.clamav.home = lib.mkForce "${stateDir}/clamav";
  services.clamav = {
    daemon.settings.DatabaseDirectory = lib.mkForce "${stateDir}/clamav";
    updater.settings.DatabaseDirectory = lib.mkForce "${stateDir}/clamav";
  };

  # Enable virtual All and Flagged mailboxes
  services.dovecot2 = {
    settings = let
      mailDir = config.mailserver.storage.path;
      hs = config.mailserver.hierarchySeparator;
    in {
      mail_plugins = {
        virtual = true;
        notify = true;
      };
      "service doveadm" = {
        "inet_listener doveadm".port = cfg.doveadmPort;
        doveadm_password = "<${doveadmPasswordFile}";
      };
      "namespace virtual" = {
        prefix = "virtual${hs}";
        separator = hs;
        type = "private";
        mail_path = "/etc/dovecot/virtual";
        mail_index_path = "${mailDir}/.virtual/%{user | domain}/%{user | username}";
        mail_control_path = "${mailDir}/.virtual/%{user | domain}/%{user | username}";
        mail_volatile_path = "${mailDir}/.virtual/%{user | domain}/%{user | username}";
      };
        # {
        #   _section.name = "doveadm";
        #   inet_listener.port = doveadmPort;
        #   doveadm_password = "<${doveadmPasswordFile}";
        # }
    };
  };

  environment.etc."dovecot/virtual/All Mail/dovecot-virtual" = {
    user = config.services.dovecot2.settings.mail_uid;
    group = config.services.dovecot2.settings.mail_gid;
    mode = "0444";
    text = ''
      *
      -Trash
      -Trash/*
        all
    '';
  };

  mailserver =
    {
      enable = true;
      inherit accounts;
      inherit (cfg) domains fqdn sendingFqdn;

      # Features
      # Use systemd-resolved
      localDnsResolver = false;
      virusScanning = true;
      lmtpSaveToDetailMailbox = false;
      fullTextSearch = {
        enable = true;
        memoryLimit = 8000; # MiB
      };

      # IMAP
      enableImap = true;
      enableImapSsl = true;
      enableManageSieve = true;
      hierarchySeparator = "/";
      storage.directoryLayout = "fs";

      enableSubmission = true;
      enableSubmissionSsl = true;

      indexDir = "${stateDir}/indexing";
      storage.path = "${stateDir}/mailboxes";
      dkim = {
        defaults.selector = cfg.dkimSelector;
        keyDirectory = "${stateDir}/dkim";
      };

      # SSL Certs
      x509 = {
        privateKeyFile = "${certPath}/key.pem";
        certificateFile = "${certPath}/fullchain.pem";
      };

      # Custom mailboxes configuration to enable autoexpunge
      mailboxes = {
        Trash = {
          auto = "create";
          special_use = "\\Trash";
          autoexpunge = "60d";
        };
        Junk = {
          auto = "subscribe";
          special_use = "\\Junk";
          autoexpunge = "90d";
        };
        Drafts = {
          auto = "subscribe";
          special_use = "\\Drafts";
        };
        Sent = {
          auto = "subscribe";
          special_use = "\\Sent";
        };
        Archive = {
          auto = "subscribe";
          special_use = "\\Archive";
        };
        "virtual/All Mail" = {
          auto = "no";
          special_use = "\\All";
        };
      };
    };
}

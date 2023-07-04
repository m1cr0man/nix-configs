{ domain, config, lib, ... }:
let
  localSecrets = import ./secrets.nix;
  inherit (localSecrets { inherit config lib; }) domains loginAccounts sopsEntries;

  stateDir = config.m1cr0man.container.stateDir;
  certPath = config.security.acme.certs."${config.mailserver.fqdn}".directory;
in
{
  sops.secrets = sopsEntries;
  users.users.virtualMail.extraGroups = [ "acme" ];

  # Fix clamav state directory
  users.users.clamav.home = lib.mkForce "${stateDir}/clamav";
  services.clamav = {
    daemon.settings.DatabaseDirectory = lib.mkForce "${stateDir}/clamav";
    updater.settings.DatabaseDirectory = lib.mkForce "${stateDir}/clamav";
  };

  # Enable virtual All and Flagged mailboxes
  services.dovecot2 = {
    mailPlugins.globally.enable = [ "virtual" ];
    extraConfig =
      let
        mailDir = config.mailserver.mailDirectory;
        hs = config.mailserver.hierarchySeparator;
      in
      ''
        namespace {
          prefix = virtual${hs}
          separator = ${hs}
          type = private
          location = virtual:/etc/dovecot/virtual:INDEX=${mailDir}/.virtual/%d/%n:CONTROL=${mailDir}/.virtual/%d/%n:VOLATILEDIR=${mailDir}/.virtual/%d/%n
        }
      '';
  };

  environment.etc."dovecot/virtual/All Mail/dovecot-virtual" = {
    user = config.services.dovecot2.mailUser;
    group = config.services.dovecot2.mailGroup;
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
      inherit domains loginAccounts;
      fqdn = "mail.${domain}";

      # Has to match reverse record for host
      sendingFqdn = "unimog.${domain}";

      # Change DKIM selector so that other domains
      # can safely use our DKIM key
      dkimSelector = "m1cr0man";

      # Features
      # Use systemd-resolved
      localDnsResolver = false;
      virusScanning = true;
      lmtpSaveToDetailMailbox = "no";
      fullTextSearch = {
        enable = true;
        enforced = "body";
        memoryLimit = 8000; # MiB
      };

      # IMAP
      enableImap = true;
      enableImapSsl = true;
      enableManageSieve = true;
      hierarchySeparator = "/";
      useFsLayout = true;

      enableSubmission = true;
      enableSubmissionSsl = true;

      indexDir = "${stateDir}/indexing";
      mailDirectory = "${stateDir}/mailboxes";
      sieveDirectory = "${stateDir}/sieve";
      dkimKeyDirectory = "${stateDir}/dkim";

      # SSL Certs
      keyFile = "${certPath}/key.pem";
      certificateFile = "${certPath}/fullchain.pem";
      certificateScheme = 1;

      # Custom mailboxes configuration to enable autoexpunge
      mailboxes = {
        Trash = {
          auto = "create";
          specialUse = "Trash";
          autoexpunge = "60d";
        };
        Junk = {
          auto = "subscribe";
          specialUse = "Junk";
          autoexpunge = "90d";
        };
        Drafts = {
          auto = "subscribe";
          specialUse = "Drafts";
        };
        Sent = {
          auto = "subscribe";
          specialUse = "Sent";
        };
        Archive = {
          auto = "subscribe";
          specialUse = "Archive";
        };
        "virtual/All Mail" = {
          auto = "no";
          specialUse = "All";
        };
      };
    };
}

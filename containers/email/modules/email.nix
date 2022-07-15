{ domain, config, lib, ... }:
let
  localSecrets = builtins.extraBuiltins.readSops ./secrets.nix.enc;
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
      fullTextSearch.enable = true;
      fullTextSearch.enforced = "body";
      lmtpSaveToDetailMailbox = "no";

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
      };
    };
}

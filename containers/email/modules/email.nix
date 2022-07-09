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

      # IMAP
      # TLS 143 > SSL 993
      enableImap = true;
      enableImapSsl = false;
      enableManageSieve = true;
      hierarchySeparator = "/";
      useFsLayout = true;

      # TLS 587 > SSL 465
      enableSubmission = true;
      enableSubmissionSsl = false;

      indexDir = "${stateDir}/indexing";
      mailDirectory = "${stateDir}/mailboxes";
      sieveDirectory = "${stateDir}/sieve";
      dkimKeyDirectory = "${stateDir}/dkim";

      # SSL Certs
      keyFile = "${certPath}/key.pem";
      certificateFile = "${certPath}/fullchain.pem";
      certificateScheme = 1;
    };
}

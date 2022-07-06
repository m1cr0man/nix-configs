{ config, pkgs, lib, ... }:
let
  domain = "blamethe.tools";
  stateDir = "/var/lib/email";
in
{
  system.stateVersion = "22.11";

  nixosContainer =
    {
      ephemeral = true;
      bridge = "br-containers";
      forwardPorts =
        builtins.map
          (port: { hostPort = port; containerPort = port; })
          [
            25
            # IMAP TLS
            143
            # SMTP Submission
            587
            # Sieve
            4190
          ];
      bindMounts = [
        "/var/lib/${domain}/email:${stateDir}"
        "/var/lib/acme/${domain}"
        "/etc/ssh:/etc/ssh"
      ];
    };

  users.users.virtualMail.extraGroups = [ "acme" ];
  sops.secrets.lucas_hashed_password = { };

  users.users.clamav.home = lib.mkForce "${stateDir}/clamav";
  services.clamav = {
    daemon.settings.DatabaseDirectory = lib.mkForce "${stateDir}/clamav";
    updater.settings.DatabaseDirectory = lib.mkForce "${stateDir}/clamav";
  };

  mailserver =
    {
      enable = true;
      fqdn = "mail.${domain}";
      sendingFqdn = "unimog.${domain}";
      domains = [ domain ];

      # Features
      # Use systemd-resolved
      localDnsResolver = false;
      virusScanning = true;
      fullTextSearch.enable = true;

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
      keyFile = "/var/lib/acme/${domain}/key.pem";
      certificateFile = "/var/lib/acme/${domain}/fullchain.pem";
      certificateScheme = 1;

      loginAccounts = {
        "lucas@${domain}" = {
          # Generate with
          hashedPasswordFile = config.sops.secrets.lucas_hashed_password.path;
          aliases = [ "postmaster@${domain}" "abuse@${domain}" ];
        };
      };
    };
}

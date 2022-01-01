{ config, pkgs, domain, ... }:
let
  certPath = config.security.acme.certs."${domain}".directory;
in
{
  services.vault = {
    enable = true;
    package = pkgs.vault-bin;
    storageBackend = "file";
    storagePath = "/var/lib/vault";
    tlsCertFile = "${certPath}/fullchain.pem";
    tlsKeyFile = "${certPath}/key.pem";
    extraConfig = ''
      ui = true
    '';
  };

  systemd.services.vault.requires = [ "var-lib-vault.mount" ];
  systemd.services.vault.after = [ "var-lib-vault.mount" "acme-${domain}.service" ];

  networking.hosts."127.0.0.1" = [ "vault.${domain}" ];

  users.users.vault.extraGroups = [ "acme" ];

  services.httpd.virtualHosts."vault.${domain}" = {
    forceSSL = true;
    useACMEHost = domain;
    extraConfig = ''
      SSLProxyEngine on
      ProxyPass / https://vault.${domain}:8200/
    '';
  };
}

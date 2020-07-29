{ config, pkgs, ... }:
let
  certPath = config.security.acme.certs."m1cr0man.com".directory;
in {
  services.vault = {
    enable = true;
    package = pkgs.vault-bin;
    storageBackend = "file";
    storagePath = "/var/secure/vault";
    tlsCertFile = "${certPath}/fullchain.pem";
    tlsKeyFile = "${certPath}/key.pem";
    extraConfig = ''
      ui = true
    '';
  };

  systemd.services.vault.requires = [ "var-secure-vault.mount" ];
  systemd.services.vault.after = [ "var-secure-vault.mount" "acme-m1cr0man.com.service" ];

  networking.hosts."127.0.0.1" = [ "vault.m1cr0man.com" ];

  security.acme.certs."m1cr0man.com".extraDomainNames = [ "vault.m1cr0man.com" ];
  users.users.vault.extraGroups = [ "acme" ];

  services.httpd.virtualHosts."vault.m1cr0man.com" = {
    forceSSL = true;
    useACMEHost = "m1cr0man.com";
    extraConfig = ''
      SSLProxyEngine on
      ProxyPass / https://vault.m1cr0man.com:8200/
    '';
  };
}

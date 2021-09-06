let
  secrets = import ../common/secrets.nix;
  credsFile = "/var/secrets/minio_creds.env";
in {

  services.minio = {
    enable = true;
    configDir = "/var/www/minio/config";
    dataDir = [ "/var/www/minio/data" ];
    region = "EU";
  };

  security.acme.certs."m1cr0man.com".extraDomainNames = [ "s3.m1cr0man.com" ];
  services.httpd.virtualHosts."s3.m1cr0man.com" = {
    forceSSL = true;
    useACMEHost = "m1cr0man.com";
    extraConfig = "ProxyPass / http://127.0.0.1:9000/";
  };
}

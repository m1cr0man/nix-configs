let
  secrets = import ../common/secrets.nix;
in {

  services.minio = {
    enable = true;
    accessKey = secrets.minio_access_key;
    secretKey = secrets.minio_secret_key;
    configDir = "/var/www/minio/config";
    dataDir = "/var/www/minio/data";
    region = "EU";
  };

  security.acme.certs."m1cr0man.com".extraDomains."s3.m1cr0man.com" = null;
  services.httpd.virtualHosts."s3.m1cr0man.com" = {
    onlySSL = true;
    useACMEHost = "m1cr0man.com";
    extraConfig = "ProxyPass / http://127.0.0.1:9000/";
  };
}

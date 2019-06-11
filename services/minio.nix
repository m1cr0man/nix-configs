let
  secrets = import ../common/secrets.nix;
  httpdCommon = import ../common/httpd.nix;
in {

  services.minio = {
    enable = true;
    accessKey = secrets.minio_access_key;
    secretKey = secrets.minio_secret_key;
    configDir = "/zstorage/minio/config";
    dataDir = "/zstorage/minio/data";
    region = "EU";
  };

  services.traefik.configOptions.backends.minio_back.servers.gelandewagen.url = "http://localhost:9000";
  services.traefik.configOptions.frontends.minio = {
    backend = "minio_back";
    passHostHeader = true;
    routes.m1s3.rule = "Host:s3.m1cr0man.com";
  };

  security.acme.certs."m1cr0man.com".extraDomains."s3.m1cr0man.com" = null;
  services.httpd.virtualHosts = [{
    enableSSL = true;
    hostName = "s3.m1cr0man.com";
    extraConfig = httpdCommon.httpUpgrade + "ProxyPass / http://127.0.0.1:9000/";
  }];
}

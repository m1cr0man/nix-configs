let
  secrets = import ../common/secrets.nix;
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

  services.httpd.virtualHosts = [{
    hostName = "s3.m1cr0man.com";
    extraConfig = ''
      ProxyPass / http://127.0.0.1:9000/
    '';
  }];
}

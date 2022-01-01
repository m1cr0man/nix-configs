{ config, lib, domain, ... }:
let
  cfg = config.m1cr0man.minio;

  listenAddress = "127.0.0.1:9000";
  consoleAddress = "127.0.0.1:9001";
in
{
  options.m1cr0man.minio = with lib; {
    addVhost = mkOption {
      default = true;
      type = types.bool;
      description = "Whether to add an httpd vhost for s3.${domain} and ui.s3.${domain}";
    };
    credentialsEnvSecret = mkOption {
      type = types.str;
      default = "minio_credentials_env";
      description = ''
        SOPS secret with environment variables for root credentials.
      '';
    };
  };

  config = {
    services.minio = {
      enable = true;
      inherit listenAddress consoleAddress;
      configDir = "/var/lib/www/minio/config";
      dataDir = [ "/var/lib/www/minio/data" ];
      region = "EU";
      rootCredentialsFile = config.sops.secrets."${cfg.credentialsEnvSecret}".path;
    };

    # Create the sops secret stub. Uses default path + owner
    sops.secrets."${cfg.credentialsEnvSecret}" = { };

    services.httpd.virtualHosts = lib.mkIf (cfg.addVhost) {
      "s3.${domain}" = lib.m1cr0man.makeVhostProxy { host = "${listenAddress}"; };
      "ui.s3.${domain}" = lib.m1cr0man.makeVhostProxy { host = "${consoleAddress}"; };
    };
  };
}

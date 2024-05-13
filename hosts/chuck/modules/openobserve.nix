{ pkgs, config, lib, ... }:
{
  sops.secrets.openobserve_creds_envvars = {};

  virtualisation.oci-containers.containers.openobserve = {
    image = "public.ecr.aws/zinclabs/openobserve:latest";
    ports = [ "5080:5080/tcp" "5081:5081/tcp" ];
    volumes = [ "/var/lib/openobserve:/data" ];
    environmentFiles = [ config.sops.secrets.openobserve_creds_envvars.path ];
  };

  networking.firewall.allowedTCPPorts = [ 5080 5081 ];

  systemd.services.opentelemetry-collector.serviceConfig = {
    EnvironmentFile = config.sops.secrets.openobserve_creds_envvars.path;
    Group = "systemd-journal";
  };

  services.opentelemetry-collector = {
    enable = true;
    package = pkgs.opentelemetry-collector-contrib;
    settings = {
      exporters."otlp/openobserve" = {
        endpoint = "localhost:5081";
        headers = {
          Authorization = "\${env:ZO_OTEL_AUTH_HEADER}";
          organization = "default";
          stream-name = "default";
        };
        tls.insecure = true;
      };
      receivers = {
        journald.grep = ".*";
        hostmetrics.scrapers = {
          cpu = {};
          disk = {};
          # filesystem = {};
          load = {};
          memory = {};
          network = {};
          # process = {};
          paging = {};
        };
      };
      processors.batch.timeout = "10s";
      service.pipelines.metrics = {
        receivers = ["hostmetrics"];
        processors = ["batch"];
        exporters = ["otlp/openobserve"];
      };
      service.pipelines.logs = {
        receivers = ["journald"];
        processors = ["batch"];
        exporters = ["otlp/openobserve"];
      };
    };
  };
}

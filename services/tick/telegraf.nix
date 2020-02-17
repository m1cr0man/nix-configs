{ config, lib, ... }:
let
  secrets = import ../../common/secrets.nix;
in {
  services.telegraf = {
    enable = true;
    extraConfig = {
      agent = {
        interval = "10s";
        flush_interval = "30s";
        round_interval = true;
      };
      outputs.influxdb.urls = [
        "http://${config.services.influxdb.extraConfig.http.bind-address}"
      ];
      inputs = {
        minecraft = {
          server = "127.0.0.1";
          port = "25566";
          password = secrets.minecraft_rcon_password;
        };
        system = {};
        kernel = {};
        kernel_vmstat = {};
        cpu = {};
        mem = {};
        processes = {};
        swap = {};
        netstat = {};
        net.interfaces = lib.mapAttrsToList (k: v: k) config.networking.interfaces;
        disk.mount_points = lib.mapAttrsToList (k: v: k) config.fileSystems;
        diskio.devices = [ "sd[a-z]" ];
        syslog.server = "udp://127.0.0.1:6514";

        apache = if config.services.httpd.enable then [{
          urls = [ "http://127.0.0.1/.server-status?auto" ];
        }] else [];

        tail = if config.services.httpd.enable then [{
          files = [ (config.services.httpd.logDir + "/access.log") ];
          data_format = "grok";
          grok_patterns = [ "%{COMBINED_LOG_FORMAT} %{DATA:vhost}" ];
        } {
          files = [ (config.services.httpd.logDir + "/error.log") ];
          data_format = "grok";
          grok_patterns = [ "%{HTTPD24_ERRORLOG}" ];
        }] else [];
      };
    };
  };
}

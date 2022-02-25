{ config, lib, ... }:
{
  services.telegraf = {
    enable = true;
    extraConfig = {
      agent = {
        interval = "10s";
        flush_interval = "30s";
        round_interval = true;
      };
      outputs.influxdb.urls = [
        "http://127.0.0.1:8086"
      ];
      inputs = {
        zfs = { poolMetrics = true; };
        system = { };
        kernel = { };
        kernel_vmstat = { };
        cpu = { };
        mem = { };
        processes = { };
        swap = { };
        netstat = { };
        net.interfaces = lib.mapAttrsToList (k: v: k) config.networking.interfaces;
        disk.mount_points = (lib.mapAttrsToList (k: v: k) config.fileSystems);
        diskio.devices = [ "sd[a-z]" ];
        syslog.server = "udp://127.0.0.1:6514";
        socket_listener = { service_address = "tcp://127.0.0.1:8094"; };
      };
    };
  };
}

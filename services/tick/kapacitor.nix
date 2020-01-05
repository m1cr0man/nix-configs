{ config, ... }:
{
  services.kapacitor = {
    enable = true;
    bind = "127.0.0.1";
    dataDir = "/zroot/tick/kapacitor";
    extraConfig = ''
      [[influxdb]]
        name = "localhost"
        enabled = true
        default = true
        urls = [ "http://127.0.0.1:8086" ]
        kapacitor-hostname = "127.0.0.1"

        [influxdb.excluded-subscriptions]
          chronograf = [ "autogen" ]

      [logging]
        file = "STDOUT"
        level = "INFO"
    '';
  };
}

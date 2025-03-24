{ pkgs, config, ... }: let
  go2rtcPort = 1984;
  rpicam-vid = "${pkgs.m1cr0man.rpicam-apps}/bin/rpicam-vid";
in {
  services.go2rtc = {
    enable = true;
    settings = {
      streams.rpicam = "exec:${rpicam-vid} -v1 -t0 -o- --inline --width=1920 --height=1080 --denoise=cdn_fast";
      webrtc.default_query = "video=h264";
      rtsp.listen = "";
      api = {
        listen = ":${builtins.toString go2rtcPort}";
        origin = "*";
      };
      log = {
        level = "info";
        format = "text";
        "time" = "";
      };
    };
  };

  services.nginx.virtualHosts."${config.services.mainsail.hostName}".locations = {
      "/webcam/" = {
        proxyPass = "http://localhost:${builtins.toString go2rtcPort}/";
        recommendedProxySettings = true;
        proxyWebsockets = true;
      };
  };

  # WebRTC (go2rtc)
  networking.firewall.allowedTCPPorts = [ 8555 ];
  networking.firewall.allowedUDPPorts = [ 8555 ];

  environment.systemPackages = [ pkgs.m1cr0man.rpicam-apps ];
}

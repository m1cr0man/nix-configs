{ pkgs, config, lib, ... }:
{
  services.mediamtx = {
    enable = true;
    package = pkgs.mediamtx.overrideAttrs (final: prev: {
      version = "1.16.1";
      src = pkgs.fetchFromGitHub {
        owner = "bluenviron";
        repo = "mediamtx";
        tag = "v1.16.1";
        hash = "sha256-GNerv0iniOFsVXZxbhyc0q21zkuLI6n7l/8JNvsSJY0=";
      };
      vendorHash = "sha256-Rz3PRAoqCpxyRRlJSOg9tZfj50uL6ZsRPb9wAD72of4=";
    });
    settings = {
      paths.wedding = {
        record = false;
        alwaysAvailable = false;
        # alwaysAvailableTracks = [{ codec = "H264"; } { codec = "MPEG4Audio"; samplerate = "48000"; }];
        # alwaysAvailableFile = "/var/lib/wedding/stream_loading.mp4";
      };
      webrtc = false;
      rtsp = false;
    };
  };
  # Write access to /var/lib/wedding
  systemd.services.mediamtx.serviceConfig.Group = lib.mkForce "nextcloud";
  networking.firewall.allowedTCPPorts = [ 8888 8890 ];
  networking.firewall.allowedUDPPorts = [ 8888 8890 ];
}

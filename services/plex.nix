{
  services.plex = {
    enable = true;
    openFirewall = true;
    dataDir = "/var/secure/plex";
  };
  systemd.services.plex.serviceConfig.UMask = "0077";
}

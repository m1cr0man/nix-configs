{
  services.plex = {
    enable = true;
    openFirewall = false;
    dataDir = "/var/lib/plex";
  };

  # Only allow important ports
  networking.firewall.allowedTCPPorts = [ 32400 ];

  systemd.services.plex.requires = [ "var-lib-plex.mount" ];
  systemd.services.plex.after = [ "var-lib-plex.mount" "acme-m1cr0man.com.service" ];

  systemd.services.plex.serviceConfig.UMask = "0077";
}

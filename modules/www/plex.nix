{
  services.plex = {
    enable = true;
    openFirewall = false;
  };

  # Only allow important ports
  networking.firewall.allowedTCPPorts = [ 32400 ];

  systemd.services.plex.after = [ "var-lib-plex.mount" "acme-m1cr0man.com.service" ];

  systemd.services.plex.serviceConfig.UMask = "0077";
}

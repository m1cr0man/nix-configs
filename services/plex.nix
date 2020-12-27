{
  services.plex = {
    enable = true;
    openFirewall = true;
    dataDir = "/var/lib/plex";
  };

  systemd.services.plex.requires = [ "var-lib-plex.mount" ];
  systemd.services.plex.after = [ "var-lib-plex.mount" "acme-m1cr0man.com.service" ];

  systemd.services.plex.serviceConfig.UMask = "0077";
}

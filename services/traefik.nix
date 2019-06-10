{
  services.traefik.enable = true;
  services.traefik.configOptions.file.watch = true;
  services.traefik.configOptions.defaultEntryPoints = [ "http" ];
  services.traefik.configOptions.entryPoints.http.address = ":80";
}

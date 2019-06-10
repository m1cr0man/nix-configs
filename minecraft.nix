{ pkgs, ... }:
{
  imports = [];

  nixpkgs.config.allowUnfree = true;
  services.minecraft-server = {
    enable = true;
    eula = true;

    package = pkgs.minecraft-server;

    dataDir = "/zstorage/craig_mc";

    declarative = false;

    jvmOpts = "-Xmx8G -Xms8G";

    openFirewall = false;
  };
}

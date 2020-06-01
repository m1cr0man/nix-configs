{
  gelandewagen = { config, pkgs, ... }: {
    deployment.targetHost = "144.76.44.123";
    imports = [ ./hosts/gelandewagen/configuration.nix ];
  };
}

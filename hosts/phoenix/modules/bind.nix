{ config, domain, ... }:
let
  dataDir = "/var/lib/bind";

  makeZone = name: {
    inherit name;
    file = "${dataDir}/${name}.db";
    master = true;
  };
in
{
  services.bind.zones = [
    (makeZone "donegalfirstaidservices.com")
  ];
}

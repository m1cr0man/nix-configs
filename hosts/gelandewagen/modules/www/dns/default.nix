{ config, domain, ... }:
let
  dataDir = "/var/lib/www/bind";

  keyName = "rfc2136.key.${domain}.";

  makeZone = name: {
    inherit name;
    file = "${dataDir}/${name}.db";
    master = true;
    extraConfig = "allow-update { key ${keyName}; };";
  };
in
{
  services.bind.zones = [
    (makeZone "m1cr0man.com")
    (makeZone "cragglerock.cf")
  ];

  systemd.services.bind-copy-zones = {
    wantedBy = [ "bind.service" ];
    before = [ "bind.service" ];
    description = "Copies initial zones on first start";
    script = ''
      cp -n ${./m1cr0man.com.db} m1cr0man.com.db
      cp -n ${./cragglerock.cf.db} cragglerock.cf.db
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "www/bind";
      WorkingDirectory = dataDir;
      User = "named";
      Group = "named";
      UMask = 0007;
    };
  };
}

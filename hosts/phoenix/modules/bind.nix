{ pkgs, lib, config, domain, ... }:
let
  dataDir = "/var/lib/bind";

  makeZone = name: {
    inherit name;
    file = "${dataDir}/${name}.db";
    master = true;
  };

  cfg = config.services.bind;

  # Upstream runs a checkconf without accounting for extra files living outside the nix store.
  # We need to build the bind conf ourselves to circumvent this.
  bindRndcMacType = "hmac-sha256";

  bindRndcKeyFile = "/etc/bind/rndc.key";

  testRndcKey = pkgs.writeTextFile {
    name = "testrndc.key";
    text = ''
      key "rndc-key" {
        algorithm ${bindRndcMacType};
        secret "Ini0XSebb9LrYz7zprobBLZ2iwBEK5S9vh9zj/DozR8=";
      };
    '';
  };

  bindConf = pkgs.writeTextFile {
    name = "named.conf";
    text = ''
      include "${testRndcKey}";
      controls {
        inet 127.0.0.1 allow {localhost;} keys {"rndc-key";};
      };

      acl cachenetworks { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.cacheNetworks} };
      acl badnetworks { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.blockedNetworks} };

      options {
        listen-on { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.listenOn} };
        listen-on-v6 { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.listenOnIpv6} };
        allow-query-cache { cachenetworks; };
        blackhole { badnetworks; };
        forward ${cfg.forward};
        forwarders { ${lib.concatMapStrings (entry: " ${entry}; ") cfg.forwarders} };
        directory "${cfg.directory}";
        pid-file "/run/named/named.pid";
        ${cfg.extraOptions}
      };

      ${cfg.extraConfig}

      ${lib.concatMapStrings (
        {
          name,
          file,
          master ? true,
          slaves ? [ ],
          masters ? [ ],
          allowQuery ? [ ],
          extraConfig ? "",
        }:
        ''
          zone "${name}" {
            type ${if master then "master" else "slave"};
            file "${file}";
            ${
              if master then
                ''
                  allow-transfer {
                    ${lib.concatMapStrings (ip: "${ip};\n") slaves}
                  };
                ''
              else
                ''
                  masters {
                    ${lib.concatMapStrings (ip: "${ip};\n") masters}
                  };
                ''
            }
            allow-query { ${lib.concatMapStrings (ip: "${ip}; ") allowQuery}};
            ${extraConfig}
          };
        ''
      ) (lib.attrValues cfg.zones)}
    '';
  };
in
{
  services.bind.configFile = bindConf;
  services.bind.zones = [
    (makeZone "donegalfirstaidservices.com")
  ];
}

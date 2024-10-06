{ config, lib, pkgs, domain, ... }:
let
  sopsPerms = {
    owner = "dnssync";
    group = "dnssync";
  };
  mkRecord = name: kind: content: { inherit name kind content; };

  hostName = config.networking.hostName;
  vmDomain = "${hostName}.vm.${domain}";
in {
  sops.secrets.dnssync_cloudflare_api_key = sopsPerms;
  sops.secrets.dnssync_headscale_api_key = sopsPerms;

  dnssync = {
    enable = true;
    backends = {
      headscale = {
        enable = true;
        domain = "ts.${domain}";
        addUserSuffix = true;
        baseUrl = "https://headscale.${domain}";
        keyFile = config.sops.secrets.dnssync_headscale_api_key.path;
      };
      machinectl = {
        enable = true;
        domain = vmDomain;
        includedCidrs = [
          "beef::/64"
          "192.168.25.0/24"
        ];
      };
      jsonfile = {
        enable = true;
        source = pkgs.writeText "dnssync.json" (builtins.toJSON [
          (mkRecord "grafana.int.${domain}" "cname"
            "monitoring.${vmDomain}")
          (mkRecord "monitoring.int.${domain}" "cname"
            "monitoring.${vmDomain}")
        ]);
      };
    };
    frontends = {
      cloudflare = {
        enable = true;
        inherit domain;
        instanceId = hostName;
        keyFile = config.sops.secrets.dnssync_cloudflare_api_key.path;
      };
    };
  };
}

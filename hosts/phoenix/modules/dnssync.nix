{ config, lib, pkgs, ... }:
let
  domain = "m1cr0man.com";
  sopsPerms = {
    owner = "dnssync";
    group = "dnssync";
  };
  mkRecord = name: kind: content: { inherit name kind content; };
in {
  sops.secrets.dnssync_cloudflare_api_key = sopsPerms;

  dnssync = {
    enable = true;
    backends = {
      machinectl = {
        enable = true;
        domain = "vm.${config.networking.hostName}.${domain}";
        includedCidrs = [
          "beee::/64"
          "192.168.26.0/24"
        ];
      };
    };
    frontends = {
      cloudflare = {
        enable = true;
        inherit domain;
        instanceId = config.networking.hostName;
        keyFile = config.sops.secrets.dnssync_cloudflare_api_key.path;
      };
    };
  };
}

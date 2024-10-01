{ config, lib, pkgs, ... }:
let
  sopsPerms = {
    owner = "dnssync";
    group = "dnssync";
  };
in {
  sops.secrets.dnssync_cloudflare_api_key = sopsPerms;
  sops.secrets.dnssync_headscale_api_key = sopsPerms;

  dnssync = {
    enable = true;
    extraArgs = ["--dry-run"];
    backend = {
      headscale = {
        enable = true;
        domain = "ts.m1cr0man.com";
        addUserSuffix = true;
        baseUrl = "https://headscale.m1cr0man.com";
        keyFile = config.sops.secrets.dnssync_headscale_api_key.path;
      };
      machinectl = {
        enable = true;
        domain = "vms.${config.networking.hostName}.m1cr0man.com";
        includedCidrs = [
          "beef::/64"
          "192.168.25.0/24"
        ];
      };
    };
    frontend = {
      cloudflare = {
        enable = true;
        domain = "m1cr0man.com";
        keyFile = config.sops.secrets.dnssync_cloudflare_api_key.path;
      };
    };
  };
}

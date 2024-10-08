{ config, lib, ... }:
let
  localSecrets = builtins.extraBuiltins.readSops ./secrets.nix.enc;
  domain = "vccomputers.ie";
in
{
  m1cr0man.mailserver = {
    enable = true;
    inherit (localSecrets { inherit config lib; }) domains loginAccounts;

    fqdn = "mail.${domain}";
    # Has to match reverse record for host
    sendingFqdn = "phoenix.${domain}";
    dkimSelector = "vcc";

    stateDir = config.m1cr0man.container.stateDir;

    replicationPeer = "email.unimog.vm.m1cr0man.com";
  };

  # Force using the VCC cloudflare sops secret
  sops.secrets.acme_cloudflare_env.sopsFile = lib.mkForce config.sops.defaultSopsFile;

  networking.firewall.allowedTCPPorts = [ config.m1cr0man.mailserver.doveadmPort ];
}

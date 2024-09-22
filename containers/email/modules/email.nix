{ domain, config, lib, ... }:
let
  localSecrets = builtins.extraBuiltins.readSops ./secrets.nix.enc;
in
{
  m1cr0man.mailserver = {
    enable = true;
    inherit (localSecrets { inherit config lib; }) domains loginAccounts;

    fqdn = "mail.${domain}";
    # Has to match reverse record for host
    sendingFqdn = "unimog.${domain}";
    dkimSelector = "m1cr0man";

    stateDir = config.m1cr0man.container.stateDir;

    replicationPeer = "192.168.26.197";
  };

  networking.firewall.allowedTCPPorts = [ config.m1cr0man.mailserver.doveadmPort ];
}

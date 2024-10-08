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

    replicationPeer = "vccemail.phoenix.vm.m1cr0man.com";
  };

  networking.firewall.allowedTCPPorts = [ config.m1cr0man.mailserver.doveadmPort ];
}

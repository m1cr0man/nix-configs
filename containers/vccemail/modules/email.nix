{ config, lib, ... }:
let
  localSecrets = builtins.extraBuiltins.readSops ./secrets.nix.enc;
  domain = "vccomputers.ie";
in
{
  config.m1cr0man.mailserver = {
    enable = true;
    inherit (localSecrets { inherit config lib; }) domains loginAccounts;

    fqdn = "mail.${domain}";
    # Has to match reverse record for host
    sendingFqdn = "phoenix.${domain}";
    dkimSelector = "vcc";

    stateDir = config.m1cr0man.container.stateDir;
  };
}

{ pkgs, config, lib, ... }:
let
  sender_whitelist = pkgs.writeText "sender_whitelist" (
    builtins.concatStringsSep "\n" (
      builtins.map (
        dom: "sysmail@${dom} OK"
      ) config.m1cr0man.mailserver.domains
    )
  );
in
{
  services.postfix = {
    mapFiles = { inherit sender_whitelist; };
    config = {
      # Match milters for all types of mail.
      # This means all mail filters through rspamd.
      non_smtpd_milters = lib.mkBefore ["unix:/run/rspamd/rspamd-milter.sock"];
    };
  };
}

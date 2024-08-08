{ lib, config, domain, ... }:
let
  inherit (lib) types mkOption mkEnableOption;
in
{
  options.m1cr0man.mailserver = {
    enable = mkEnableOption "a mail server suite powered by simple NixOS mailserver";

    fqdn = mkOption {
      type = types.str;
      default = "mail.${domain}";
      description = "Mail server FQDN, used for SSL validation";
    };

    sendingFqdn = mkOption {
      type = types.str;
      default = "mail.${domain}";
      description = "Sending FQDN, which must match reverse records for the host";
    };

    dkimSelector = mkOption {
      type = types.str;
      default = "default";
      description = "DKIM selector. This should be set such that it does not overlap other mail server clusters";
    };

    domains = mkOption {
      type = types.listOf types.str;
      default = [ domain ];
      description = "Domains which we are serving email for";
    };

    loginAccounts = mkOption {
      type = types.attrs;
      default = {};
      description = "SNM loginAccounts. See here for docs: https://nixos-mailserver.readthedocs.io/en/latest/options.html#mailserver-loginaccounts";
    };

    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/snm";
      description = "Where to store mailboxes, A/V data, sieve scripts, etc";
    };

    doveadmPort = mkOption {
      type = types.ints.positive;
      default = 2993;
      description = "Port to serve doveadm on";
    };

    replicationPeer = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "IP/Hostname of host to replicate with";
    };
  };
}

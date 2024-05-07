{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "secrets"
      "www/acme-base.nix"
    ]
    ++
    addModulesRecursive ./modules;

  system.stateVersion = "24.05";

  nixosContainer =
    {
      forwardPorts =
        builtins.map
          (port: { hostPort = port; containerPort = port; })
          [
            25
            # IMAP TLS
            143
            993
            # SMTP Submission
            465
            587
            # Sieve
            4190
            # Radicale
            5232
          ];
      bindMounts = [
        stateDir
        "${stateDir}/nixos:/var/lib/nixos"
        "${stateDir}/rspamd:/var/lib/rspamd"
        "${stateDir}/dhparams:/var/lib/dhparams"
        "${stateDir}/dovecot:/var/lib/dovecot"
        "${stateDir}/opendkim:/var/lib/opendkim"
        "${stateDir}/redis-rspamd:/var/lib/redis-rspamd"
        "${stateDir}/rspamd:/var/lib/rspamd"
      ];
    };
}

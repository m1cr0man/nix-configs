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

  system.stateVersion = "22.11";

  nixosContainer =
    {
      forwardPorts =
        builtins.map
          (port: { hostPort = port; containerPort = port; })
          [
            25
            # IMAP TLS
            143
            # SMTP Submission
            587
            # Sieve
            4190
            # Radicale
            5232
          ];
      bindMounts = [
        stateDir
        "${stateDir}/rspamd:/var/lib/rspamd"
        "${stateDir}/dhparams:/var/lib/dhparams"
        "${stateDir}/dovecot:/var/lib/dovecot"
        "${stateDir}/opendkim:/var/lib/opendkim"
        "${stateDir}/redis-rspamd:/var/lib/redis-rspamd"
        "${stateDir}/rspamd:/var/lib/rspamd"
      ];
    };
}

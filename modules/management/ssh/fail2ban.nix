{ config, ... }:
let
  port = builtins.toString (builtins.head config.services.openssh.ports);
in
{
  services.fail2ban = {
    enable = true;

    jails = {
      # Docs: https://github.com/fail2ban/fail2ban/blob/master/config/action.d/iptables-common.conf
      ssh = ''
        enabled = true
        filter = sshd
        maxretry = 25
        action = iptables[name=SSH, port=${port}, protocol=tcp]
      '';
      sshd-ddos = ''
        enabled  = true
        filter = sshd-ddos
        maxretry = 25
        action   = iptables[name=SSH, port=${port}, protocol=tcp]
      '';
    };
  };
}

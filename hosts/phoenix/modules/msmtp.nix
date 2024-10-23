{ config, ... }:
{
  users.groups.sendmail = {};

  programs.msmtp = {
    enable = true;
    defaults.logfile = "~/msmtp.log";
    accounts.default = {
      auth = true;
      tls = true;
      port = 587;
      # try setting `tls_starttls` to `false` if sendmail hangs
      from = "sysmail@vccomputers.net";
      host = "mail.vccomputers.ie";
      user = "sysmail@m1cr0man.com";
      # Within the environment of PHPFPM, there are minimal commands available in the PATH.
      # Avoid using cat and instead use printf and shell pipes.
      passwordeval = "printf %s \"$(<${config.sops.secrets.sysmail_password.path})\"";
    };
  };

  sops.secrets.sysmail_password = {
    mode = "0440";
    group = "sendmail";
  };
}

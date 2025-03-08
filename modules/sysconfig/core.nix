{ config, ... }:
{
  # Enable accounting so systemd-cgtop can show IO load
  systemd.enableCgroupAccounting = true;

  # Fix for infinite recursion when RFC108 is enabled
  # See https://github.com/NixOS/nixpkgs/issues/353225
  networking.resolvconf.enable = !config.services.resolved.enable;

  # Localisation
  time.timeZone = "Europe/Dublin";
  i18n.defaultLocale = "en_IE.UTF-8";
}

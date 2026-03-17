{ callPackage }:
{
  scripts = callPackage ./scripts { };
  m1cr0blog = callPackage ./m1cr0blog { };
  vcc-hugo = callPackage ./vcc-hugo { };
  mc-monitor = callPackage ./mc-monitor { };
  upd72020x = callPackage ./upd72020x { };
  upgrade-pg-cluster = callPackage ./upgrade-pg-cluster { };
  rpicam-apps = callPackage ./rpicam-apps { };
  libcamera-rpi = callPackage ./libcamera-rpi { };
}

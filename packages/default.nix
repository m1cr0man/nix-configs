{ callPackage }:
{
  scripts = callPackage ./scripts { };
  m1cr0blog = callPackage ./m1cr0blog { };
  mc-monitor = callPackage ./mc-monitor { };
  upd72020x = callPackage ./upd72020x { };
}

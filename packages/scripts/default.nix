{ callPackage, symlinkJoin }:
symlinkJoin {
  name = "scripts";
  paths = [
    (callPackage ./scan-network { })
    (callPackage ./zfs-unlocker { })
  ];
}

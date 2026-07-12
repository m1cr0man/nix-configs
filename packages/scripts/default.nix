{ callPackage, symlinkJoin }:
symlinkJoin {
  name = "scripts";
  paths = [
    (callPackage ./scan-network { })
    (callPackage ./machinectl-prom-sd { })
    (callPackage ./zfs-unlocker { })
  ];
}

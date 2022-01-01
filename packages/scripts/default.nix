{ callPackage, symlinkJoin }:
symlinkJoin {
  name = "scripts";
  paths = [
    (callPackage ./scan-network.nix { })
    (callPackage ./zfs-unlocker { })
  ];
}

let
  nixpkgsPath = <nixpkgs>;
  pkgs = import nixpkgsPath {};
  yarn2nix = pkgs.fetchFromGitHub {
    owner = "Profpatsch";
    repo = "yarn2nix";
    rev = "919012b32c705e57d90409fc2d9e5ba49e05b471";
    sha256 = "1f9gw31j7jvv6b2fk5h76qd9b78zsc9ac9hj23ws119zzxh6nbyd";
  };
  nixLib = pkgs.callPackage (yarn2nix + "/nix-lib") {
    # WARNING (TODO): for now you need to use this checked out yarn2nix
    # because the upstream package (in haskellPackages) might have
    # broken dependencies (yarn-lock and yarn2nix are not in stackage)
    yarn2nix = import yarn2nix { inherit nixpkgsPath; };
  };

in
  nixLib.buildNodePackage ({
    src = nixLib.removePrefixes [ "node_modules" ] ./.;
    } // (nixLib.callTemplate ./npm-package.nix (nixLib.buildNodeDeps (pkgs.callPackage ./npm-deps.nix {}))))

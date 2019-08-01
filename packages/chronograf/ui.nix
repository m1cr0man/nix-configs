{ pkgs ? import <nixpkgs> {}, version ? null, chronografSrc ? null }:
let
  yarn2nix = import (pkgs.fetchFromGitHub {
    owner = "moretea";
    repo = "yarn2nix";
    rev = "3f2dbb08724bf8841609f932bfe1d61a78277232";
    sha256 = "142av7dwviapsnahgj8r6779gs2zr17achzhr8b97s0hsl08dcl2";
  }) {inherit pkgs;};

in yarn2nix.mkYarnPackage {
  name = "chronograf-ui";
  src = chronografSrc + "/ui";
  packageJSON = chronografSrc + "/ui/package.json";
  yarnLock = chronografSrc + "/ui/yarn.lock";
  dontCopyDist = true;
  installPhase = ''
    export BUILDDIR=$(pwd)
    export NODE_PATH=$(pwd)/node_modules:$NODE_PATH
    cd $src
    $BUILDDIR/node_modules/.bin/parcel build -d $out/build --no-source-maps --no-cache --public-url "" src/index.html
    cd -
  '';
  distPhase = "true";
}

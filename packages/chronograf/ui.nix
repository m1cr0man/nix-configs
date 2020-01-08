{ pkgs ? import <nixpkgs> {}, version ? null, chronografSrc ? null }:
let
  yarn2nix = import (pkgs.fetchFromGitHub {
    owner = "moretea";
    repo = "yarn2nix";
    rev = "3f2dbb08724bf8841609f932bfe1d61a78277232";
    sha256 = "142av7dwviapsnahgj8r6779gs2zr17achzhr8b97s0hsl08dcl2";
  }) {inherit pkgs;};

in yarn2nix.mkYarnPackage rec {
  name = "chronograf-ui";
  src = chronografSrc + "/ui";
  packageJSON = chronografSrc + "/ui/package.json";
  yarnLock = chronografSrc + "/ui/yarn.lock";
  extraBuildInputs = with pkgs; [ python pkgconfig ];
  dontCopyDist = true;
  configurePhase = ''
    # Use this when pkgs.libsass is compatible with the version node-sass wants
    # export LIBSASS_EXT=auto

    # Link node-modules but make node-sass writable
    mkdir node_modules
    for f in $node_modules/* $node_modules/.[0-9a-z]*; do ln -s $f node_modules/; done
    rm node_modules/node-sass
    cp -ar $node_modules/node-sass node_modules/
    chmod -R +w node_modules/node-sass

    # Rebuild node-sass since it has native dependencies
    npm rebuild node-sass --no-update-notifier --nodedir=${pkgs.nodejs} -j max --silent
    PARCEL_WORKERS=4 npx parcel build -d build --no-source-maps --no-cache --public-url "" --log-level 2 src/index.html
  '';
  installPhase = ''
    mkdir -p $out
    mv build $out/build
  '';
  distPhase = "true";
}

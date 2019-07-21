{ pkgs ? import <nixpkgs> {} }:

let
  yarn2nix = import (pkgs.fetchFromGitHub {
    owner = "moretea";
    repo = "yarn2nix";
    rev = "2b29eafedd3822095187ba20a472c2b01642b09d";
    sha256 = "0cvjb3n988643i7kk2fq313cfd2dbnnm5948fbh7r56fn3l5ridv";
  }) {inherit pkgs;};

  version = "1.7.12";
  chronografSrc = pkgs.fetchFromGitHub {
    owner = "influxdata";
    repo = "chronograf";
    rev = version;
    sha256 = "1p0a67qvx7rhx79kds7l0r6svxs7aq570xzhmahaicmxsrqwxq16";
  };

  yarnPkg = yarn2nix.mkYarnPackage {
    name = "chronograf-ui-node-pkgs";
    src = chronografSrc + "/ui";
    packageJSON = chronografSrc + "/ui/package.json";
    yarnLock = chronografSrc + "/ui/yarn.lock";
    unpackPhase = ":";
    publishBinsFor = ["parcel-bundler"];
  };
in pkgs.stdenv.mkDerivation {
  name = "chronograf-ui";
  src = chronografSrc + "/ui";

  buildInputs = [
    yarnPkg
    pkgs.yarn
    pkgs.git
  ];

  patchPhase = ''
    ln -sf ${yarnPkg}/node_modules .
  '';

  shellHook = ''
    ln -sf ${yarnPkg}/node_modules .
  '';

  installPhase = ''
    mkdir -p $out
    parcel build -d $out --no-source-maps --public-url "" src/index.html
  '';
}

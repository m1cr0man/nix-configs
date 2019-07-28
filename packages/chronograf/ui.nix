{ pkgs ? import <nixpkgs> {}, version ? null, chronografSrc ? null }:
let
  version = "1.7.12";
  chronografSrc = pkgs.fetchFromGitHub {
    owner = "influxdata";
    repo = "chronograf";
    rev = version;
    sha256 = "1p0a67qvx7rhx79kds7l0r6svxs7aq570xzhmahaicmxsrqwxq16";
  };

  yarn2nix = import (pkgs.fetchFromGitHub {
    owner = "moretea";
    repo = "yarn2nix";
    rev = "3f2dbb08724bf8841609f932bfe1d61a78277232";
    sha256 = "142av7dwviapsnahgj8r6779gs2zr17achzhr8b97s0hsl08dcl2";
  }) {inherit pkgs;};

  yarnPkg = yarn2nix.mkYarnPackage {
    name = "chronograf-ui-node-pkgs";
    src = chronografSrc + "/ui";
    packageJSON = chronografSrc + "/ui/package.json";
    yarnLock = chronografSrc + "/ui/yarn.lock";
    postInstall = "ln -s $out/libexec/chronograf-ui/node_modules $out/node_modules";
    publishBinsFor = ["parcel"];
  };
in pkgs.stdenv.mkDerivation {
  name = "chronograf-ui";
  src = chronografSrc + "/ui";

  buildInputs = [
    pkgs.nodejs-10_x
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
    # This needs to run twice due to some bug
    # /etc/nixos/packages/chronograf/dev/ui/src/sources/components/ConnectionWizard.tsx: Cannot find module '@babel/plugin-proposal-class-properties' from '/etc/nixos/packages/chronograf/dev/ui'
    # The problem package changes, seems to be some race condition. Only happens when dependencies need to be built.
    ${yarnPkg}/bin/parcel build -d $out --no-source-maps --no-cache --public-url "" src/index.html || ${yarnPkg}/bin/parcel build -d $out --no-source-maps --no-cache --public-url "" src/index.html
  '';
}

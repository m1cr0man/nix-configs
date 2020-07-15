{ pkgs ? import <nixpkgs> {}, nodejs ? pkgs.nodejs, version ? "1.8.5", fetchFromGitHub ? pkgs.fetchFromGitHub, chronografSrc ? fetchFromGitHub {
  owner = "m1cr0man";
  repo = "chronograf";
  rev = "d177306267d8c4e61800c15723a5ca755445a4bc";
  sha256 = "0agsr249lx2m451897r586d3ypjz8md30pp545mnprqx535v697q";
}
}:
(pkgs.yarn2nix-moretea.mkYarnPackage {
  inherit nodejs;
  name = "chronograf-ui";
  src = chronografSrc + "/ui";

  postConfigure = ''
    cd deps/chronograf-ui
    PARCEL_WORKERS=4 npx parcel build -d build --no-source-maps --no-cache --public-url "" --log-level 3 src/index.html
  '';

  installPhase = ''
    mkdir -p $out
    mv build $out/build
  '';

  distPhase = "true";
  dontCopyDist = true;

  pkgConfig = {
    node-sass = {
      buildInputs = [ pkgs.python ];
      preInstall = ''
        ${nodejs}/lib/node_modules/npm/bin/node-gyp-bin/node-gyp --nodedir ${nodejs} configure
        ${nodejs}/lib/node_modules/npm/bin/node-gyp-bin/node-gyp --nodedir ${nodejs} build
        mkdir -p vendor/linux-x64-72
        mv build/Release/binding.node vendor/linux-x64-72/binding.node
      '';
    };
  };
})

{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib, buildGoModule ? pkgs.buildGoModule, fetchFromGitHub ? pkgs.fetchFromGitHub }:
let
  version = "1.7.12";
  chronografSrc = fetchFromGitHub {
    owner = "influxdata";
    repo = "chronograf";
    rev = version;
    sha256 = "1p0a67qvx7rhx79kds7l0r6svxs7aq570xzhmahaicmxsrqwxq16";
  };

  chronoUi = import ./ui.nix { inherit pkgs version chronografSrc; };
in buildGoModule rec {
  inherit version;

  name = "chronograf-${version}";
  src = chronografSrc;

  modSha256 = "0c8inpcf1p3h1mp7xwhywvh9j4ws68hm9010w85psc78r1z1na2d";

  buildInputs = [ pkgs.go-bindata ];
  preBuild = ''
    ln -s ${chronoUi}/build ui/build
    make .bindata
  '';

  buildFlagsArray = [ ''-ldflags=
    -X main.version=${version}
  '' ];

  excludedPackages = "test";

  subPackages = [ "cmd/chronoctl" "cmd/chronograf" ];

  meta = with lib; {
    description = "Open source monitoring and visualization UI for the TICK stack";
    license = licenses.agpl3;
    homepage = https://influxdb.com/;
    maintainers = [{
      email = "lucas+nix@m1cr0man.com";
      github = "m1cr0man";
      name = "Lucas Savva";
    }];
  };
}
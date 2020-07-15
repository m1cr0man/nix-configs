{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib, buildGoModule ? pkgs.buildGoModule, fetchFromGitHub ? pkgs.fetchFromGitHub }:
let
  version = "1.8.5";
  chronografSrc = fetchFromGitHub {
    owner = "m1cr0man";
    repo = "chronograf";
    rev = "d177306267d8c4e61800c15723a5ca755445a4bc";
    sha256 = "0agsr249lx2m451897r586d3ypjz8md30pp545mnprqx535v697q";
  };

  chronoUi = import ./ui.nix { inherit pkgs version chronografSrc; };
in buildGoModule rec {
  inherit version;

  name = "chronograf-${version}";
  src = chronografSrc;

  vendorSha256 = "0saxrlk5r1yphhlf2x06i804djz6bjszg6i2pi21g4lx1kckvq8k";

  nativeBuildInputs = [ pkgs.go-bindata ];
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

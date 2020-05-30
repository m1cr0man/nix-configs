{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib, buildGoModule ? pkgs.buildGoModule, fetchFromGitHub ? pkgs.fetchFromGitHub }:
let
  version = "1.8.4";
  chronografSrc = fetchFromGitHub {
    owner = "influxdata";
    repo = "chronograf";
    rev = version;
    sha256 = "1fmzcvqsvy3ahpwbavsw2qa9v97apfwziyid622v3yi3bsj38jhb";
  };

  chronoUi = import ./ui.nix { inherit pkgs version chronografSrc; };
in buildGoModule rec {
  inherit version;

  name = "chronograf-${version}";
  src = chronografSrc;

  vendorSha256 = "0dzqsyqpagq75mlpppdg3skbnixaq12g7m2kx4nsgs1zbqh4kqlq";

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

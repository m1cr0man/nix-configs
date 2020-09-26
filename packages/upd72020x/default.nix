{ pkgs ? import <nixpkgs> {} }:
let
  firmware = pkgs.requireFile {
    name = "K2026.mem";
    sha256 = "15sgcfr80ayf6rvjv8z8b77hwhrnh0s84w5i6q408gf74k160x8p";
    message = "Need firmware for USB controller";
  };

in pkgs.stdenv.mkDerivation {
  name = "upd72020x";
  version = "2.0.2.6";
  src = pkgs.fetchFromGitHub {
    owner = "markusj";
    repo = "upd72020x-load";
    rev = "444f9a957dc85ec9cd178e5e9b046e665017aaa0";
    sha256 = "08np2rxjqwhhnbds7nxnxmncr40qwwkkwi9x0dnfwi4z2spv9icw";
    fetchSubmodules = true;
  };
  installPhase = ''
    mkdir -p $out/bin $out/firmware
    cp upd72020x-load $out/bin
    chmod +x $out/bin/*
    cp ${firmware} $out/firmware/K2026.mem
  '';
}

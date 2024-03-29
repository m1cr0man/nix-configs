{ fetchFromGitHub, requireFile, stdenv }:
let
  firmware = requireFile {
    name = "K2026.mem";
    sha256 = "15sgcfr80ayf6rvjv8z8b77hwhrnh0s84w5i6q408gf74k160x8p";
    message = ''
      Need firmware for USB controller (K2026.mem)
      Add it to the store with nix-store --add-fixed sha256 K2026.mem
    '';
  };

in
stdenv.mkDerivation {
  name = "upd72020x";
  version = "2.0.2.6";

  src = fetchFromGitHub {
    owner = "markusj";
    repo = "upd72020x-load";
    rev = "444f9a957dc85ec9cd178e5e9b046e665017aaa0";
    sha256 = "08np2rxjqwhhnbds7nxnxmncr40qwwkkwi9x0dnfwi4z2spv9icw";
    fetchSubmodules = false;
  };

  installPhase = ''
    mkdir -p $out/bin $out/firmware
    cp upd72020x-load $out/bin
    chmod +x $out/bin/*
    cp ${firmware} $out/firmware/K2026.mem
  '';

  meta.description = "Renesas USB controller firmware for early SandyBridge mobos";
}

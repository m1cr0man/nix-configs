{ lib, rustPlatform }:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rsvp-saver";
  version = "1.0.0";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    description = "Wedding RSVP saver";
    maintainers = [ lib.maintainers.m1cr0man ];
  };
})

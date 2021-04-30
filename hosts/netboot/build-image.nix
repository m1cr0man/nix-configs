# To build: nix-build build-image.nix
{ pkgs ? import <nixpkgs> {}, }:
let
  configuration = import ./configuration.nix;
  nixos = import "${<nixpkgs>}/nixos" {
    inherit configuration;
  };
in
pkgs.symlinkJoin {
  name = "netboot";
  paths = with nixos.config.system.build; [
    netbootRamdisk
    kernel
    netbootIpxeScript
  ];
  preferLocalBuild = true;
}

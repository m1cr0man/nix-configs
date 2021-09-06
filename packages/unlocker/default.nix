{ pkgs ? import <nixpkgs> }:
pkgs.writeShellScriptBin "unlocker" ''
  ${pkgs.python3}/bin/python3 ${./unlocker.py} $@
''

{ pkgs ? import <nixpkgs> {} }:
let
  fetchGitHubZip = { owner, repo, rev, sha256 }: pkgs.fetchzip {
    inherit sha256;
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
  };

  nixpkgs = fetchGitHubZip {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "135073a87b7e2c631739f4ffa016e1859b1a425e";
    sha256 = "0s5kgyi7764r4zm51zy4isyc4zgn4fajwqwnrgm7s1xbs6zickv5";
  };

  nixops = import (fetchGitHubZip {
    owner = "NixOS";
    repo = "nixops";
    rev = "68aa76845573a8e6613286a730f0a2c9e394af97";
    sha256 = "1w8km1rf8hghp2jfvlbwqa2zsf9xaxbn8rzjy1zar4n42lcnfspn";
  }) { inherit pkgs; };
  node2nix = import (fetchGitHubZip {
    owner = "svanderburg";
    repo = "node2nix";
    rev = "be792edbdbf66f453e92c2a5adbf1cfac180f21c";
    sha256 = "1pq7zi6d85q9k3mdnn7pl5zs198a424sf3m4vvnyxqgjvs29dg9m";
  }) { inherit pkgs; };
in pkgs.stdenv.mkDerivation rec {
  name = "nixops-shell";

  buildInputs = [
    nixops
    pkgs.nodePackages.node2nix
  ];

  shellHook = ''
    export NIX_PATH="nixpkgs=${nixpkgs}:."
    export NIXOPS_STATE="./state.nixops"

    if [ ! -e packages/m1cr0blog/default.nix ]; then
      cd packages/m1cr0blog
      node2nix --nodejs-12 -i packages.json
      cd -
    fi
  '';
}

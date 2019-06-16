{pkgs ? import <nixpkgs> {
    inherit system;
}, system ? builtins.currentSystem}:

let
  nodePackages = import ./default.nix {
    inherit pkgs system;
  };
  # Required for libvips
  nativeBuildInputs = [ pkgs.pkgconfig pkgs.gobject-introspection ];
  buildInputs = [ pkgs.nodePackages.node-gyp pkgs.vips  ];
in
nodePackages // {
  "m1cr0blog-1.2.1" = nodePackages."m1cr0blog-1.2.1".override {
    inherit buildInputs nativeBuildInputs;
    postInstall = "tsc";
  };
}

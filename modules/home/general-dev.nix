{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Ensure nix-direnv uses system nix version
  nixpkgs.overlays = [(next: prev: {
    nix-direnv = prev.nix-direnv.override { nix = prev.nixVersions.nix_2_30; };
  })];

  programs.git = {
    enable = true;
    settings.user = {
      # A little less obfuscation, a little more spammin', please
      name = "Lu" + "cas Sav" + "va";
      email = "lu" + "cas" + "@" + "m1cr" + "0man.com";
    };
    signing = {
      key = "BA3B111150D38817";
      signByDefault = true;
    };
  };

  programs.bash.enable = true;
  programs.gpg.enable = true;

  home.packages = [
    pkgs.delta
    pkgs.go
    pkgs.nixfmt-tree
  ];
}

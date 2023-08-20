{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Ensure nix-direnv uses system nix version
  nixpkgs.overlays = [(next: prev: {
    nix-direnv = prev.nix-direnv.override { nix = prev.nixVersions.nix_2_17; };
  })];

  programs.git = {
    enable = true;
    # A little less obfuscation, a little more spammin', please
    userName = "Lu" + "cas Sav" + "va";
    userEmail = "lu" + "cas" + "@" + "m1cr" + "0man.com";
    signing = {
      key = "BA3B111150D38817";
      signByDefault = true;
    };
  };

  programs.bash.enable = true;
  programs.gpg.enable = true;
}

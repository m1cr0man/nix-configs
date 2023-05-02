{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    # A little less obfuscation, a little more spammin', please
    userName = "Lu" + "cas Sav" + "va";
    userEmail = "lu" + "cas" + "@" + "m1cr" + "0man.com";
    signing = {
      key = "F9CE6D3DCDC78F2D";
      signByDefault = true;
    };
  };

  programs.bash.enable = true;
  programs.gpg.enable = true;
}

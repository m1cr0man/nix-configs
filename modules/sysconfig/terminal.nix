{ pkgs, ... }:
{
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  programs.bash = {
    interactiveShellInit = ''
      # Save each command in history as soon as it is executed
      PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
      HISTCONTROL='ignoreboth'
      HISTSIZE=5000
      HISTFILESIZE=20000

      SHOPTFLAGS=(
        # Enable zsh-style globbing
        globstar
        # CD niceness
        autocd
        cdspell
        # Multiline commands in history
        cmdhist
        lithist
        # Append to history
        histappend
      )

      shopt -s "''${SHOPTFLAGS[@]}"

      # Zsh-like completion
      bind 'set show-all-if-ambiguous on'
      bind 'TAB:menu-complete'
    '';
  };

  # Some packages I want in every environment
  environment.systemPackages = with pkgs; [
    git
    htop
    screen
    vim
    wget
    zstd
    sops
    nix-prefetch-github
    rsync
  ];
}

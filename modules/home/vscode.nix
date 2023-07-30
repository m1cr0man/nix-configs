{ pkgs, lib, config, ... }:
{
  options.m1cr0man.vscode = {
    remoteEditor = lib.mkEnableOption "openvscode-server as the EDITOR";
  };

  config = {
    programs.vscode = let
      loadAfter = deps: pkg: pkg.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs or [] ++ [ pkgs.jq pkgs.moreutils ];

        preInstall = old.preInstall or "" + ''
          jq '.extensionDependencies |= . + $deps' \
            --argjson deps ${lib.escapeShellArg (builtins.toJSON deps)} \
            package.json | sponge package.json
        '';
      });

      editor = if config.m1cr0man.vscode.remoteEditor then "openvscode-server" else "code";
    in {
      enable = true;
      mutableExtensionsDir = false;
      extensions = with pkgs.vscode-extensions;
      # Extensions which do not need direnv
      [
        # General
        mkhl.direnv
        # Nix dev
        bbenoist.nix
        # Rust dev
        vadimcn.vscode-lldb
      ] ++ map (loadAfter [ "mkhl.direnv" ])
      # Extensions depending on direnv
      [
        # Nix dev
        jnoortheen.nix-ide
        # Rust dev
        # ## Will always use a direnv rust-analyzer
        (rust-lang.rust-analyzer.override { setDefaultServerPath = false; })
        # Python dev
        ms-python.python
        ms-python.vscode-pylance
        ms-pyright.pyright
      ];
      userSettings = {
        "editor.minimap.enabled" = false;
        "files.insertFinalNewline" = true;
        "files.trimFinalNewlines" = true;
        "files.trimTrailingWhitespace" = true;
        "[nix]"."editor.tabSize" = 2;
        "terminal.integrated.env.linux"."EDITOR" = "${editor} --wait";
        "terminal.integrated.localEchoEnabled" = "off";
        "workbench.startupEditor" = "none";
        "telemetry.telemetryLevel" = "off";
        "update.mode" = "none";
      };
    };

    # Create a symlink between openvscode-server's configs
    # and actual vscode's.
    home.file = let
      hd = config.home.homeDirectory;
      machineConfig = "${config.xdg.configHome}/Code/Machine/settings.json";
      userConfig = "${config.xdg.configHome}/Code/User/settings.json";
    in {
      ".openvscode-server".source = pkgs.runCommand "openvscode-server-link" {} ''
        mkdir -p $out
        cd $out
        ln -s ${hd}/.vscode/extensions extensions
        ln -s ${hd}/.config/Code data
      '';
      # Similarly link the machine settings and user settings together
      # This way openvscode-server will read the machine settings
      # on startup.
      "${machineConfig}".source = config.home.file."${userConfig}".source;
    };
  };
}

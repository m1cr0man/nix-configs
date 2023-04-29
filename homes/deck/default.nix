{ pkgs, lib, ... }:
{
  home = {
    stateVersion = "23.05";
    username = "deck";
    homeDirectory = "/home/deck";
    packages = with pkgs; [
      cura
      discord
      lutris
      wineWowPackages.stagingFull
      ((prismlauncher.override { jdks = [ jdk17 jdk8 ]; }).overrideAttrs (prev: {
          postInstall =
          let
            libpath = with xorg;
            lib.makeLibraryPath [
              libX11
              libXext
              libXcursor
              libXrandr
              libXxf86vm
              libpulseaudio
              libGL
              glfw
              openal
              stdenv.cc.cc.lib
              pkgs.flite
              pkgs.alsa-lib
            ];
          in
          ''
            # xorg.xrandr needed for LWJGL [2.9.2, 3) https://github.com/LWJGL/lwjgl/issues/128
            wrapQtApp $out/bin/prismlauncher \
            --set LD_LIBRARY_PATH /run/opengl-driver/lib:${libpath} \
            --prefix PRISMLAUNCHER_JAVA_PATHS : ${lib.makeSearchPath "bin/java" [ jdk17 jdk8 ]} \
            --prefix PATH : ${lib.makeBinPath [xorg.xrandr]}
          '';
      }))
    ];
  };

  manual.manpages.enable = false;

  programs.opera = {
    enable = true;
    package = pkgs.opera.override { proprietaryCodecs = true; };
    extensions = [
      {
        id = "gnblbpbepfbfmoobegdogkglpbhcjofh";
      }
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.vscode = let
    loadAfter = deps: pkg: pkg.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs or [] ++ [ pkgs.jq pkgs.moreutils ];

      preInstall = old.preInstall or "" + ''
        jq '.extensionDependencies |= . + $deps' \
          --argjson deps ${lib.escapeShellArg (builtins.toJSON deps)} \
          package.json | sponge package.json
      '';
    });
  in {
    enable = true;
    extensions = with pkgs.vscode-extensions;
    # Extensions which do not need direnv
    [
      # General
      mkhl.direnv
      # Nix dev
      bbenoist.nix
      jnoortheen.nix-ide
      # Rust dev
      vadimcn.vscode-lldb
    ] ++ map (loadAfter [ "mkhl.direnv" ])
    # Extensions depending on direnv
    [
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
      "terminal.integrated.env.linux"."EDITOR" = "code --wait";
      "terminal.integrated.localEchoEnabled" = "off";
      "workbench.startupEditor" = "none";
      "telemetry.telemetryLevel" = "off";
    };
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
  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableSshSupport = true;
    enableScDaemon = false;
    pinentryFlavor = "gnome3";
  };
  systemd.user.services.gpg-agent.Service.Environment = [ "LISTEN_FDNAMES=std:ssh:extra" ];
}

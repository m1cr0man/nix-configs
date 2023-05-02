{ pkgs, lib, ... }:
{
  imports = [
    ../../modules/home/general-dev.nix
    ../../modules/home/vscode.nix
  ];

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

  # Repurposing
  programs.vivaldi = {
    enable = true;
    package = pkgs.opera.override { proprietaryCodecs = true; };
    extensions = [
      {
        id = "gnblbpbepfbfmoobegdogkglpbhcjofh";
      }
    ];
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

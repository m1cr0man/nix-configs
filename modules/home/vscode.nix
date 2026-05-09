{ pkgs, lib, config, ... }:
let
  cfg = config.m1cr0man.vscode;
  home = config.home.homeDirectory;
  vscodeSocket = "${home}/.cache/openvscode-server.sock";
in
{
  options.m1cr0man.vscode = {
    remoteEditor = lib.mkEnableOption "openvscode-server as the EDITOR";
    serverSocket = lib.mkOption {
      type = lib.types.path;
      default = "${home}/.openvscode-server.sock";
      description = "Path to the OpenVSCode server listening socket";
    };
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
      profiles.default.extensions = with pkgs.vscode-extensions;
      # Extensions which do not need direnv
      [
        # General
        mkhl.direnv
        rooveterinaryinc.roo-cline
        (pkgs.vscode-utils.extensionFromVscodeMarketplace {
          publisher = "Google";
          name = "geminicodeassist";
          version = "2.81.0";
          sha256 = "sha256-QX0YPHPQPYl2LRHGmXTL146Kxty/YMlvRo503eWEMpg=";
        })
        # Rust dev
        vadimcn.vscode-lldb
        tamasfe.even-better-toml
        # Go dev
        golang.go
        # AI
        (pkgs.vscode-utils.extensionFromVscodeMarketplace {
          publisher = "reduckted";
          name = "vscode-gitweblinks";
          version = "2.14.1";
          sha256 = "sha256-7rYh1Nt9ZlhKzttINm1zdDtYBZprrgRr/8xd9rTKrCw=";
        })
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
        charliermarsh.ruff
        (pkgs.vscode-utils.extensionFromVscodeMarketplace {
          publisher = "astral-sh";
          name = "ty";
          version = "2026.44.0";
          sha256 = "sha256-1/nNZjXfJZjLlcvFMKNsp9txh+DzDKTn60WfY4ksX2Y=";
        })
        # OC/CC dev
        (pkgs.vscode-utils.extensionFromVscodeMarketplace {
          publisher = "exeteres";
          name = "oc-ts";
          version = "0.2.2";
          sha256 = "sha256-3Ih+Rcv5zm+/WJV6ph8q07qNYpuNiyxcyRZ9naPzokI=";
        })
        (pkgs.vscode-utils.extensionFromVscodeMarketplace {
          publisher = "subtixx";
          name = "opencomputerslua";
          version = "0.1.1";
          sha256 = "sha256-ohiqgFP+ZKmG6HsPq6R/o72t35WEqFM5GreonHubBiA=";
        })
      ];
      profiles.default.userSettings = {
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

    # This will be started on demand by the socket unit.
    systemd.user.services.openvscode-server = {
      Unit = {
        Description = "Open VSCode Server";
        # Required so that the service shuts down when no connections remain
        BindsTo = [ "openvscode-server-proxy.service" ];
      };
      Service = {
        ExecStart = "${pkgs.openvscode-server}/bin/openvscode-server --telemetry-level=off --socket-path=${vscodeSocket} --accept-server-license-terms --without-connection-token";
        ExecStartPre = "bash -c 'test -e ${vscodeSocket} && rm ${vscodeSocket} || true'";
        ExecSearchPath = [ "${pkgs.coreutils}/bin" "${pkgs.git}/bin" "${pkgs.gnused}/bin" "${home}/.nix-profile/bin" "/nix/profile/bin" "${home}/.local/state/nix/profile/bin" "/etc/profiles/per-user/lucas/bin" "/run/current-system/sw/bin" ];
      };
    };

    # See mongodb module for more info on how this operates
    systemd.user.services."openvscode-server-proxy" = {
      Unit = {
        Description = "Connects clients to openvscode-server via systemd sockets";
        BindsTo = [ "openvscode-server-proxy.socket" ];
        Requires = [ "openvscode-server.service" ];
        After = [ "openvscode-server-proxy.socket" "openvscode-server.service" ];
      };

      Service = {
        ExecStart = "${pkgs.systemd.out}/lib/systemd/systemd-socket-proxyd --exit-idle-time=15min ${vscodeSocket}";
        Type = "notify";
      };
    };

    systemd.user.sockets.openvscode-server-proxy = {
      Unit.Description = "Open VSCode Server Listening Socket";
      Install.WantedBy = [ "default.target" ];
      Socket = {
        ListenStream = cfg.serverSocket;
        # One proxy service per listener connection
        Accept = false;
        SocketMode = "0600";
      };
    };
  };
}

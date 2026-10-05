{ pkgs, lib, config, ... }:
let
  cfg = config.m1cr0man.vscode;
  home = config.home.homeDirectory;
  vscodeSocket = "${home}/.cache/code-server.sock";
in
{
  options.m1cr0man.vscode = {
    remoteEditor = lib.mkEnableOption "code-server as the EDITOR";
    serverSocket = lib.mkOption {
      type = lib.types.path;
      default = "${home}/.code-server.sock";
      description = "Path to the code server listening socket";
    };
  };

  config = {
    programs.claude-code.enable = true;

    programs.vscode = let
      loadAfter = deps: pkg: pkg.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs or [] ++ [ pkgs.jq pkgs.moreutils ];

        preInstall = old.preInstall or "" + ''
          jq '.extensionDependencies |= . + $deps' \
            --argjson deps ${lib.escapeShellArg (builtins.toJSON deps)} \
            package.json | sponge package.json
        '';
      });

      editor = if config.m1cr0man.vscode.remoteEditor then "code-server" else "code";
    in {
      enable = true;
      mutableExtensionsDir = false;
      profiles.default.extensions = with pkgs.vscode-extensions;
      # Extensions which do not need direnv
      [
        # General
        mkhl.direnv
        # Rust dev
        vadimcn.vscode-lldb
        tamasfe.even-better-toml
        # Go dev
        golang.go
        (pkgs.vscode-utils.extensionFromVscodeMarketplace {
          publisher = "reduckted";
          name = "vscode-gitweblinks";
          version = "2.15.1";
          sha256 = "sha256-ckRPvOh1XldBY4mElBDI+Lheip/zsXH250jUgv9Z8cw=";
        })
        # AI
        (pkgs.vscode-utils.extensionFromVscodeMarketplace {
          publisher = "Google";
          name = "google-antigravity";
          version = "1.5.0";
          sha256 = "sha256-M8DSpZmnznljLCVitwOCEhWOMOeyk04i2K/EGA2kJ5w=";
        })
        anthropic.claude-code
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
          version = "2026.76.0";
          sha256 = "sha256-R0WSkM6LQNsGi5tCYH79AOYJycFdsOERrGi8jncEtAU=";
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
        "chat.agent.enabled" = false;
        "chat.checkpoints.enabled" = false;
        "chat.editor.localAgent.enabled" = false;
        "chat.disableAIFeatures" = true;
      };
    };

    home.file = let
      machineConfig = "${config.xdg.configHome}/Code/Machine/settings.json";
      userConfig = "${config.xdg.configHome}/Code/User/settings.json";
    in {
      # Link the machine settings and user settings together
      # This way code-server will read the machine settings
      # on startup.
      "${machineConfig}".source = config.home.file."${userConfig}".source;
    };

    # This will be started on demand by the socket unit.
    systemd.user.services.code-server = {
      Unit = {
        Description = "VSCode Server";
        # Required so that the service shuts down when no connections remain
        BindsTo = [ "code-server-proxy.service" ];
      };
      Service = {
        ExecStart = "${pkgs.code-server}/bin/code-server --disable-telemetry --disable-update-check --socket=${vscodeSocket} --user-data-dir %E/Code --extensions-dir %h/.vscode/extensions --auth none";
        ExecStartPre = "bash -c 'test -e ${vscodeSocket} && rm ${vscodeSocket} || true'";
        ExecSearchPath = [ "${pkgs.coreutils}/bin" "${pkgs.git}/bin" "${pkgs.gnused}/bin" "${home}/.nix-profile/bin" "/nix/profile/bin" "${home}/.local/state/nix/profile/bin" "/etc/profiles/per-user/lucas/bin" "/run/current-system/sw/bin" ];
      };
    };

    # See mongodb module for more info on how this operates
    systemd.user.services."code-server-proxy" = {
      Unit = {
        Description = "Connects clients to code-server via systemd sockets";
        BindsTo = [ "code-server-proxy.socket" ];
        Requires = [ "code-server.service" ];
        After = [ "code-server-proxy.socket" "code-server.service" ];
      };

      Service = {
        ExecStart = "${pkgs.systemd.out}/lib/systemd/systemd-socket-proxyd --exit-idle-time=15min ${vscodeSocket}";
        Type = "notify";
      };
    };

    systemd.user.sockets.code-server-proxy = {
      Unit.Description = "VSCode Server Listening Socket";
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

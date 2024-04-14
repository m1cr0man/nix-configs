{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.m1cr0man.imhumane-rs;

  description = "ImHumane Anti bot form validator";

  coreEnvironment = lib.mapAttrs'
    (k: v: {
      value = builtins.toString v;
      name = "IMHUMANE_" + (lib.m1cr0man.lowerCamelToScreamingSnake k);
    })
    (cfg.imageConfig // {
      inherit (cfg) listenerAddress;
    });

  listenerEnvironment = lib.mapAttrs'
    (k: v: {
      value = builtins.toString v;
      name = "IMHUMANE_LISTENER_" + (lib.strings.toUpper k);
    })
    (cfg.extraListenerOptions);

  environment = coreEnvironment // listenerEnvironment // {
    RUST_LOG = cfg.logLevel;
    RUST_LOG_STYLE = "SYSTEMD";
  };

in {
  options.m1cr0man.imhumane-rs = {
    enable = mkEnableOption description;

    imageConfig = {
      imagesDirectory = mkOption {
        type = types.path;
        description = "Path to the directory containing source images. Must be writable.";
      };
      gridLength = mkOption {
        type = types.numbers.positive;
        default = 3;
        description = "Number of images on each axis of the grid.";
      };
      imageSize = mkOption {
        type = types.numbers.positive;
        default = 96;
        description = "The size of each individual image, in pixels.";
      };
      gapSize = mkOption {
        type = types.numbers.positive;
        default = 8;
        description = "The width of the gap between images, in pixels.";
      };
      bufferSize = mkOption {
        type = types.numbers.positive;
        default = 8;
        description = "The number of challenges to pre-generate.";
      };
      threads = mkOption {
        type = types.numbers.positive;
        default = 8;
        description = "The number of challenge generation threads.";
      };
    };

    listenerAddress = mkOption {
      type = types.str;
      default = "./listener.sock";
      description = "Any listening address supported by tokio_listener. See https://docs.rs/tokio-listener/latest/tokio_listener/struct.UserOptions.html";
    };

    logLevel = mkOption {
      type = types.enum [ "error" "warn" "info" "debug" "trace" ];
      default = "info";
      description = "Log level of the service";
    };

    extraListenerOptions = mkOption {
      type = types.attrs;
      default = {
        unix_listen_unlink = true;
      };
      description = "UserOptions to pass to tokio_listener. See https://docs.rs/tokio-listener/latest/tokio_listener/struct.UserOptions.html";
    };
  };

  config = {
    users.groups.imhumane = {};

    users.users.imhumane = {
      inherit description;
      group = "imhumane";
      home = "/var/empty";
      createHome = false;
      isSystemUser = true;
      isNormalUser = false;
      useDefaultShell = false;
    };

    systemd.services.imhumane-rs = {
      inherit description environment;
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        User = "imhumane";
        Group = "imhumane";
        NoNewPrivileges = true;
        ExecStart = "${pkgs.imhumane}/bin/imhumane";
        RuntimeDirectory = "imhumane-rs";
        WorkingDirectory = "%t/imhumane-rs";
        Restart = "always";
        RestartSec = 10;
      };
    };
  };
}

# Helpers for writing modules
# Imported as an overlay in flake.nix
# Exposed as lib.m1cr0man
{ domain, lib }:
rec {
  inherit domain;

  # PolicyKit helpers
  polkit = import ./polkit.nix;

  module = import ./module.nix;

  # Configures a given SOPS secret name for use with
  # a specific user. The "key" optional arg is used
  # when you must customise name per-service on a
  # one-key-to-many-service secret.
  setupSopsSecret = { name, user ? "root", key ? name }: {
    users.users."${user}".extraGroups = [ "keys" ];
    sops.secrets."${key}".owner = user;
  };

  # Sets up a vhost forcing SSL and useACMEHost
  makeVhost = { forceSSL ? true, useACMEHost ? domain, ... }@args: { inherit forceSSL useACMEHost; } // args;

  makeLocationProxy = { host, protocol ? "http", location ? "/", extraConfig ? "" }: {
    proxyPass = "${protocol}://${host}/";
    extraConfig = ''
      ${extraConfig}
      RewriteEngine On
      RewriteCond %{HTTP:Upgrade} =websocket [NC]
      RewriteRule ${location}(.*)           ws://${host}/$1 [P,L]
    '';
  };

  # Same as above but for reverse proxying with websocket support.
  # Additional args can be added to the result attrset with the // syntax.
  makeVhostProxy = { location ? "/", ... }@args: (makeVhost {
    locations."${location}" = makeLocationProxy args;
  });

  makeNormalUser = name: { description ? "Manged by NixOS Config", keys ? [ ], group ? name, home ? "/home/${name}", extraArgs ? { } }: {
    "${name}" = {
      inherit name description group home;
      openssh.authorizedKeys.keys = keys;
      createHome = true;
      isSystemUser = false;
      isNormalUser = true;
      useDefaultShell = true;
    } // extraArgs;
  };

  # Converts a lowerCamelCase string to SCREAMING_SNAKE_CASE
  lowerCamelToScreamingSnake = camelStr:
    builtins.concatStringsSep
      ""
      (builtins.map
        (v: if builtins.typeOf v == "list" then "_" + (builtins.head v) else lib.strings.toUpper v)
        (builtins.split "([A-Z]+)" camelStr)
      );
}

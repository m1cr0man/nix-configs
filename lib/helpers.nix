# Helpers for writing modules
# Imported as an overlay in flake.nix
# Exposed as lib.m1cr0man
{ domain }:
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
    sops.secrets."${name}".owner = user;
  };

  # Sets up a vhost forcing SSL and useACMEHost
  makeVhost = { forceSSL ? true, useACMEHost ? domain, ... }@args: { inherit forceSSL useACMEHost; } // args;

  # Same as above but for reverse proxying with websocket support.
  # Additional args can be added to the result attrset with the // syntax.
  makeVhostProxy = { host, protocol ? "http", location ? "/", extraConfig ? "" }: (makeVhost {
    locations."${location}".proxyPass = "${protocol}://${host}/";
    extraConfig = ''
      ${extraConfig}
      RewriteEngine On
      RewriteCond %{HTTP:Upgrade} =websocket [NC]
      RewriteRule /(.*)           ws://${host}/$1 [P,L]
    '';
  });
}
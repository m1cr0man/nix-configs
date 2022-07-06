# Helper functions for flake output
{ inputs, domain, system ? builtins.currentSystem }:
with inputs;
let
  # We add the modules folder to the store and later add it to specialArgs.
  # This saves us doing long relative paths in imports for hosts.
  configPath = self;
  myModulesPath = "${configPath}/modules";
in
rec {
  inherit domain system;

  # Used for all custom packages. Makes it explicit where they come from.
  pkgRoot = "m1cr0man";

  # Add the flake's overlays to nixpkgs, and set an explicit config.
  # The "system" argument is legacy, so pass localSystem.system instead.
  # Note that this explicit overlays + config prevents local overrides
  # previously possible in ~/.config/nixpkgs/{overlays,config}.nix, but
  # the benefit is this nixpkgs will be "Pure", and I can import
  # pkgs/top-level explicitly instead of importing top-level/impure.nix first
  # (which is what `import nixpkgs` would do).
  pkgs = import "${nixpkgs.outPath}/pkgs/top-level/default.nix" {
    localSystem.system = system;
    overlays = builtins.attrValues self.overlays;
    config = { allowUnfree = true; };
  };

  # Found in oxalica's config
  # Ref: https://github.com/dramforever/config/blob/63be844019b7ca675ea587da3b3ff0248158d9fc/flake.nix#L24-L28
  systemLabelModule = { lib, ... }: {
    system.configurationRevision = self.rev or null;
    # system.nixos.revision = self.rev or null;
    system.nixos.label =
      if self.sourceInfo ? lastModifiedDate && self.sourceInfo ? shortRev
      then "${lib.substring 0 8 self.sourceInfo.lastModifiedDate}.${self.sourceInfo.shortRev}"
      else lib.warn "Repo is dirty, revision will not be available in system label" "dirty";
  };

  nixOptionsModule = { pkgs, config, ... }: {
    # Enable flakes globally.
    # Also enable nix-plugins and our own extra-builtins so we can decrypt sops at eval time for some special cases.
    nix.extraOptions =
      let
        nix-plugins = (pkgs.nix-plugins.overrideAttrs (prev: {
          src = pkgs.fetchFromGitHub {
            owner = "shlevy";
            repo = "nix-plugins";
            rev = "e3b8c5a3210adc310acc204cbd17bbcbc73c84ae";
            sha256 = "AkHsZpYM4EY8SNuF6LhxF2peOjp69ICGc3kOLkDms64=";
          };
        })).override { nix = config.nix.package; };
      in
      ''
        experimental-features = nix-command flakes
        plugin-files = ${nix-plugins}/lib/nix/plugins
        extra-builtins-file = ${configPath}/lib/extra-builtins.nix
      '';
  };

  baseModule = name: {
    # Ensure it doesn't auto-import another nixpkgs
    nixpkgs.pkgs = pkgs;

    # Pin nixpkgs so that commands like "nix shell nixpkgs#<pkg>" are more efficient
    # Source: https://www.tweag.io/blog/2020-07-31-nixos-flakes/ "Pinning Nixpkgs"
    nix.registry.nixpkgs.flake = nixpkgs;

    # Also set the NIX_PATH appropriately so legacy commands use our nixpkgs and not the
    # channels. You may have to rm ~/.nix-defexpr/channels too.
    # Kind thanks to tejingdesk for this idea:
    # https://github.com/tejing1/nixos-config/blob/222692910d9c8c44ff066f86f4a2dd1e46f629d3/nixosConfigurations/tejingdesk/registry.nix#L12
    nix.nixPath = [ "/etc/nix/path" ];
    environment.etc."nix/path/nixpkgs".source = nixpkgs;

    _module.args = {
      # Add domain to the module args so we don't have to do `config.networking.domain` everywhere.
      inherit domain;
      # Add self for... uh.. Nothing. You know what? Don't ask. Also, don't copy this.
      inherit self;
    };

    # Use the host-specific sops secrets by default
    sops.defaultSopsFile = "${configPath}/hosts/${name}/secrets.yaml";

    # Set hostname and domain name
    networking.hostName = name;
    networking.domain = domain;
  };

  # Builds a system configuration entry for nixosConfigurations.
  # nixpkgs.lib.nixosSystem is defined in nixpkg's flake.nix
  mkConfiguration =
    { name, modules ? [ ] }: nixpkgs.lib.nixosSystem {
      # These settings are required to configure the nixpkgs used for module building.
      # Without inheriting pkgs here, the defaultPkgs would be used which wouldn't include
      # our overlays.
      # See https://github.com/NixOS/nixpkgs/blob/8377a7bca967dba811899164d4218d1d4a24b483/nixos/lib/eval-config.nix#L43
      # and https://github.com/NixOS/nixpkgs/blob/0699530f08290f34c532beedd66046825d9756fa/nixos/modules/misc/nixpkgs.nix#L58
      inherit system pkgs;
      inherit (pkgs) lib;

      # args is technically deprecated/internal.
      # you shouldn't use them here (although you could).
      # instead, create a module and set _module.args = { ... }

      modules = modules ++ [
        systemLabelModule
        (baseModule name)
        nixOptionsModule
        sops-nix.nixosModules.sops
        "${configPath}/hosts/${name}/configuration.nix"
      ] ++ (pkgs.lib.m1cr0man.module.addModules myModulesPath [
        "global-options.nix"
        "secrets"
        "sysconfig"
      ]);
    };

  mkContainer =
    { name, modules ? [ ] }:
    let
      container = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        inherit (pkgs) lib;

        modules = modules ++ [
          (baseModule name)
          "${configPath}/containers/${name}/configuration.nix"
        ] ++ (pkgs.lib.m1cr0man.module.addModules myModulesPath [
          "containers"
          "secrets"
          "sysconfig/users-groups.nix"
        ]);
      };
    in
    pkgs.buildEnv {
      inherit name;
      paths = [
        container.config.system.build.toplevel
        (pkgs.writeTextDir "data" (builtins.toJSON container.config.nixosContainer))
      ];
    };

  # Checks recommended by deploy-rs
  deployChecks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

  # Builds deploy-rs' deploy.nodes entries from self.nixosConfigurations
  deployNodes =
    let
      activator = deploy-rs.lib.x86_64-linux.activate.nixos;
    in
    builtins.mapAttrs
      (hostname: conf: {
        inherit hostname;
        sshUser = "root";
        profiles.system = {
          user = "root";
          path = activator conf;
        };
      })
      self.nixosConfigurations;

  # Generates a nixosModules tree based on the filesystem tree
  autoExportedModules = (import "${configPath}/lib/module.nix").importModulesRecursive myModulesPath;
}

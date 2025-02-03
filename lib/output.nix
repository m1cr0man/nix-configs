# Helper functions for flake output
{ inputs, domain, system ? builtins.currentSystem }:
let
  inherit (inputs) self nixpkgs nixos-nspawn sops-nix;
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
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
  };

  systemLabelModule = { lib, ... }:
    let
      shortRev = self.shortRev or "dirty";
      lastMod = lib.substring 0 8 (self.lastModifiedDate or self.lastModified or "19700101");
      label = if self ? shortRev then "${lastMod}.${self.shortRev}" else "dirty";
    in
    {
      # Found ref in oxalica's config + adaptation from nixpkgs.lib.nixosSystem
      # Ref: https://github.com/dramforever/config/blob/63be844019b7ca675ea587da3b3ff0248158d9fc/flake.nix#L24-L28
      system.configurationRevision = self.rev or null;
      system.nixos.revision = self.rev or null;
      system.nixos.label = label;
      system.nixos.versionSuffix = ".${label}";
    };

  nixOptionsModule = { pkgs, config, ... }: {
    # Enable flakes globally.
    # Also enable nix-plugins and our own extra-builtins so we can decrypt sops at eval time for some special cases.
    # Always ensure nix version matches that expected by nix-plugins
    # TL;DR Bump whenever nix.conf/nix-plugins errors appear in build
    nix.package = pkgs.nixVersions.nix_2_24;
    nix.extraOptions =
      ''
        experimental-features = nix-command flakes
        plugin-files = ${pkgs.nix-plugins}/lib/nix/plugins
        extra-builtins-file = ${configPath}/lib/extra-builtins.nix
      '';
  };

  baseModule = instanceType: name: {
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

    # Set hostname and domain name
    networking.hostName = name;
    networking.domain = domain;

    # Set instanceType
    m1cr0man.instanceType = instanceType;
  };

  # My own version of nixpkgs.lib.nixosSystem as the latter evaluates
  # its whole own version of nixpkgs.lib.
  nixosSystem = modules: import "${nixpkgs.outPath}/nixos/lib/eval-config.nix"
    {
      # These settings are required to configure the nixpkgs used for module building.
      # Without inheriting pkgs here, the defaultPkgs would be used which wouldn't include
      # our overlays.
      # See https://github.com/NixOS/nixpkgs/blob/8377a7bca967dba811899164d4218d1d4a24b483/nixos/lib/eval-config.nix#L43
      # and https://github.com/NixOS/nixpkgs/blob/0699530f08290f34c532beedd66046825d9756fa/nixos/modules/misc/nixpkgs.nix#L58
      inherit system pkgs modules;
      inherit (pkgs) lib;
    };

  # Builds a system configuration entry for nixosConfigurations.
  mkConfiguration =
    { name, modules ? [ ] }: nixosSystem (
      modules ++ [
        systemLabelModule
        (baseModule "host" name)
        nixOptionsModule
        sops-nix.nixosModules.sops
        "${configPath}/hosts/${name}/configuration.nix"
      ] ++ (pkgs.lib.m1cr0man.module.addModules myModulesPath [
        "global-options.nix"
        "secrets"
        "sysconfig"
      ])
    );

  # Builds a container configuration entry for nixosContainers
  mkContainer = { name, modules ? [ ] }:
    nixos-nspawn.lib.mkContainer {
      inherit nixpkgs system pkgs name;
      modules = modules ++ [
        (baseModule "container" name)
        nixOptionsModule
        "${configPath}/containers/${name}/configuration.nix"
      ] ++ (pkgs.lib.m1cr0man.module.addModules myModulesPath [
        "global-options.nix"
        "containers"
        "sysconfig/core.nix"
        "sysconfig/users-groups.nix"
      ]);
    };

  # Generates a nixosModules tree based on the filesystem tree
  autoExportedModules = (import "${configPath}/lib/module.nix").importModulesRecursive myModulesPath;
}

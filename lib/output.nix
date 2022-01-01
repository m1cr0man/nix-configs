# Helper functions for flake output
{ self, nixpkgs, deploy-rs, sops-nix, domain, system ? builtins.currentSystem }:
let
  # We add the modules folder to the store and later add it to specialArgs.
  # This saves us doing long relative paths in imports for hosts.
  configPath = "${../.}";
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
  # TODO seems to be in upstream nixosSystem now, can probably remove it
  # Ref: https://github.com/dramforever/config/blob/63be844019b7ca675ea587da3b3ff0248158d9fc/flake.nix#L24-L28
  systemLabelModule = {
    system.configurationRevision = self.rev or null;
    # system.nixos.revision = self.rev or null;
    system.nixos.label =
      if self.sourceInfo ? lastModifiedDate && self.sourceInfo ? shortRev
      then "${nixpkgs.lib.substring 0 8 self.sourceInfo.lastModifiedDate}.${self.sourceInfo.shortRev}"
      else nixpkgs.lib.warn "Repo is dirty, revision will not be available in system label" "dirty";
  };

  # Builds a system configuration entry for nixosConfigurations.
  # nixpkgs.lib.nixosSystem is defined in nixpkg's flake.nix
  mkConfiguration =
    { name
    , modules
    }: nixpkgs.lib.nixosSystem {
      # These settings are required to configure the nixpkgs used for module building.
      # Without inheriting pkgs here, the defaultPkgs would be used which wouldn't include
      # our overlays.
      # See https://github.com/NixOS/nixpkgs/blob/8377a7bca967dba811899164d4218d1d4a24b483/nixos/lib/eval-config.nix#L43
      # and https://github.com/NixOS/nixpkgs/blob/0699530f08290f34c532beedd66046825d9756fa/nixos/modules/misc/nixpkgs.nix#L58
      inherit system pkgs;
      inherit (pkgs) lib;

      # Add a couple of helpers to specialArgs for easy relative imports
      # TODO try remove these
      specialArgs.myModulesPath = myModulesPath;
      specialArgs.addModules = pkgs.lib.m1cr0man.addModules;
      specialArgs.addModulesRecursive = pkgs.lib.m1cr0man.addModulesRecursive;

      # args is technically deprecated/internal.
      # you shouldn't use them here (although you could).
      # instead, create a module and set _module.args = { ... }

      modules = [
        systemLabelModule
        sops-nix.nixosModules.sops
        {
          # Add our overlays
          # TODO test shouldn't be necessary now
          # nixpkgs.overlays = builtins.attrValues self.overlays;
          nixpkgs.pkgs = pkgs;
          # Enable unfree packages
          # nixpkgs.config.allowUnfree = true;

          # Pin nixpkgs so that commands like "nix shell nixpkgs#<pkg>" are more efficient
          # Source: https://www.tweag.io/blog/2020-07-31-nixos-flakes/ "Pinning Nixpkgs"
          nix.registry.nixpkgs.flake = nixpkgs;

          networking.hostName = name;
          networking.domain = domain;

          # Add domain to the module args so we don't have to do `config.networking.domain` everywhere
          _module.args.domain = domain;

          # Use the host-specific sops secrets by default
          sops.defaultSopsFile = "${configPath}/hosts/${name}/secrets.yaml";
        }
        "${myModulesPath}/global-options.nix"
        "${myModulesPath}/secrets"
        "${myModulesPath}/sysconfig"
        "${configPath}/hosts/${name}/configuration.nix"
      ] ++ modules;
    };

  # Checks recommended by deploy-rs
  deployChecks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

  # Builds deploy-rs' deploy.nodes entries from self.nixosConfigurations
  deployNodes =
    let
      activator = deploy-rs.lib.x86_64-linux.activate.nixos;
    in
    builtins.mapAttrs
      (name: conf: {
        profiles.system = {
          user = "root";
          path = activator conf;
        };
      })
      self.nixosConfigurations;
}

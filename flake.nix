{
  description = "M1cr0man Nix Configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = github:Mic92/sops-nix;
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, deploy-rs, sops-nix, ... }@inputs:
    with import ./lib/output.nix
      {
        inherit self nixpkgs deploy-rs sops-nix;
        domain = "m1cr0man.com";
        system = "x86_64-linux";
      };
    {
      # All hosts managed by this repository should be added here
      # nixosConfigurations is read by `nixos-rebuild`
      nixosConfigurations = {
        # bgrs = mkConfiguration {
        #   name = "bgrs";
        # };

        # chuck = mkConfiguration {
        #   name = "chuck";
        # };

        gelandewagen = mkConfiguration {
          name = "gelandewagen";
        };

        # homegame = mkConfiguration {
        #   name = "homegame";
        # };

        # optiplexxx = mkConfiguration {
        #   name = "optiplexxx";
        # };

        # testing = mkConfiguration {
        #   name = "testing";
        # };
      };

      # The deploy attribute is used by deploy-rs
      deploy.nodes = deployNodes;
      checks = deployChecks;

      # Exported modules, for use in other people's flakes and nixosConfigurations
      nixosModules = {
        inherit systemLabelModule;
        # Best way I could think of to export the lib folder. Technically these
        # aren't modules but they aren't packages either, and really the user could
        # just use "${myflake}/lib/module.nix" but why do that if you are
        # also importing this?
        lib = {
          module = import ./lib/module.nix;
          polkit = import ./lib/polkit.nix;
          output = import ./lib/output.nix;
        };
      } // autoExportedModules;

      # Exported overlays, for use in dependent flakes and nixosConfigurations
      # Added to pkgs in lib/output.nix
      # Usually packages will be declared here since we need a nixpkgs env
      # to work from to build them.
      overlays = {
        # It's best practice to put all the packages you plan to put in the packages output (last lines)
        # into overlays first. That way, people can override the nixpkgs that is being used to build
        # the package by using the overlay directly.
        extraPackages = final: prev: {
          "${pkgRoot}" = import ./packages { callPackage = final.callPackage; };
          # If needed you can replace import with `final.callPackage` here
          lib = prev.lib.extend (f: p: { "${pkgRoot}" = import ./lib/helpers.nix { inherit domain; }; });
        };
        # Adding deploy-rs here too because I iterate + import
        # all overlays in output.nix:pkgs = import nixpkgs...
        deploy-rs = deploy-rs.overlay;
      };

      # Exported packages, for use in dependent flakes
      # Re-exports packages defined in overlays above
      # e.g. can be used with `nix build .#<pkgname>`
      # system and pkgs come from lib/output.nix
      packages."${system}" = pkgs."${pkgRoot}";

      # Configure devShell
      # Usable with `nix develop`. shell.nix provides nix-shell compat.
      # system and pkgs come from lib/output.nix
      devShell."${system}" = pkgs.mkShell {
        packages = [
          pkgs.nix-prefetch-git
          # For VS Code Nix IDE plugin
          pkgs.rnix-lsp
          # Sops related packages. Took me a moment to realise sops
          # is an independent thing from sops-nix ;)
          pkgs.age
          pkgs.sops
          pkgs.ssh-to-age
          # For deploying systems
          pkgs.deploy-rs.deploy-rs
        ];
        # I use VS Code Remote SSH.
        EDITOR = "code --wait";
      };
    };
}

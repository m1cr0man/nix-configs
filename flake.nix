{
  description = "M1cr0man Nix Configurations";

  inputs = {
    nixpkgs.url = "path:/home/lucas/ssd/nixpkgs";

    deploy-rs.url = github:serokell/deploy-rs;
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
    let
      devDeps = [
        pkgs.nix-prefetch-git
        pkgs.gnupg
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
    in
    {
      # All hosts managed by this repository should be added here
      # nixosConfigurations is read by `nixos-rebuild`
      nixosConfigurations = {
        bgrs = mkConfiguration {
          name = "bgrs";
        };

        chuck = mkConfiguration {
          name = "chuck";
        };

        gelandewagen = mkConfiguration {
          name = "gelandewagen";
        };

        optiplexxx = mkConfiguration {
          name = "optiplexxx";
        };

        unimog = mkConfiguration {
          name = "unimog";
        };

        netboot = mkConfiguration {
          name = "netboot";
          modules = [
            ({ modulesPath, ... }: {
              imports = [ "${modulesPath}/installer/netboot/netboot-minimal.nix" ];
            })
          ];
        };

        kexec = { address, prefixLength, defaultGateway }: mkConfiguration {
          name = "kexec";
          modules = [
            ({ modulesPath, ... }: {
              imports = [ "${modulesPath}/installer/kexec/kexec-boot.nix" ];
              networking = {
                inherit defaultGateway;
                usePredictableInterfaceNames = false;
                interfaces.eth0 = {
                  ipv4.addresses = [{
                    inherit address prefixLength;
                  }];
                };
              };
            })
          ];
        };
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
          # It's a bit more complex to extend lib since it's self-referential
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
      packages."${system}" = pkgs."${pkgRoot}" // {
        # Required for adding a gcroot to stop the devshell getting GC'd
        # See https://github.com/NixOS/nix/issues/2208
        # Usage: nix build .#devShellPackages -o /nix/var/nix/gcroots/per-user/$USER/devdeps
        devShellPackages = pkgs.symlinkJoin {
          name = "dev-shell-packages";
          paths = devDeps;
        };
        # As defined by https://github.com/NixOS/nixpkgs/blob/104f09f2e4a84a9845da4c0131dac34b090c4b02/nixos/modules/installer/kexec/kexec-boot.nix#L22
        # To build, run nix repl and then:
        # :lf .
        # :b packages.x86_64-linux.kexec { address = "1.2.3.4"; prefixLength = 24; defaultGateway = "1.2.3.1"; }
        kexec = args: (self.nixosConfigurations.kexec args).config.system.build.kexecBoot;
      };

      # Configure devShell
      # Usable with `nix develop`. shell.nix provides nix-shell compat.
      # system and pkgs come from lib/output.nix
      devShell."${system}" = pkgs.mkShell {
        packages = devDeps;
        # I use VS Code Remote SSH.
        EDITOR = "code --wait";
      };
    };
}

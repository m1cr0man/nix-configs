{
  description = "M1cr0man Nix Configurations";

  inputs = {
    nixpkgs.url = "github:m1cr0man/nixpkgs/rfc108-minimal";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nixos-nspawn.url = "github:m1cr0man/python-nixos-nspawn";
    nixos-nspawn.inputs.nixpkgs.follows = "nixpkgs";

    preservation.url = "github:nix-community/preservation";

    snm.url = "git+https://gitlab.com/simple-nixos-mailserver/nixos-mailserver.git?ref=master";
    snm.inputs.nixpkgs.follows = "nixpkgs";

    nixos-vscode-server.url = "github:msteen/nixos-vscode-server";
    nixos-vscode-server.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    imhumane-rs.url = "github:m1cr0man/imhumane-rs";
    imhumane-rs.inputs.nixpkgs.follows = "nixpkgs";

    mailform-rs.url = "github:m1cr0man/mailform-rs";
    mailform-rs.inputs = {
      nixpkgs.follows = "nixpkgs";
      crane.follows = "imhumane-rs/crane";
      fenix.follows = "imhumane-rs/fenix";
      advisory-db.follows = "imhumane-rs/advisory-db";
    };

    dnssync-rs.url = "github:m1cr0man/dnssync-rs";
    dnssync-rs.inputs = {
      nixpkgs.follows = "nixpkgs";
      crane.follows = "imhumane-rs/crane";
      fenix.follows = "imhumane-rs/fenix";
      advisory-db.follows = "imhumane-rs/advisory-db";
    };

    rpi-nix.url = "github:nix-community/raspberry-pi-nix";
    rpi-nix.inputs = {
      nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, sops-nix, ... }@inputs:
    with import ./lib/output.nix
      {
        inherit inputs;
        domain = "m1cr0man.com";
        system = "x86_64-linux";
      };
    let
      outputArm = import ./lib/output.nix {
        inherit inputs;
        domain = "m1cr0man.com";
        system = "aarch64-linux";
      };
      devDeps = [
        pkgs.nix-prefetch-git
        pkgs.gnupg
        pkgs.nixpkgs-fmt
        # Sops related packages. Took me a moment to realise sops
        # is an independent thing from sops-nix ;)
        pkgs.age
        pkgs.sops
        pkgs.ssh-to-age
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
          modules = [
            inputs.nixos-vscode-server.nixosModules.default
            inputs.nixos-nspawn.nixosModules.hypervisor
          ];
        };

        sarah = mkConfiguration {
          name = "sarah";
          modules = [ inputs.nixos-vscode-server.nixosModules.default ];
        };

        dinonugget = mkConfiguration {
          name = "dinonugget";
          modules = [
            inputs.preservation.nixosModules.preservation
          ];
        };

        gelandewagen = mkConfiguration {
          name = "gelandewagen";
        };

        optiplexxx = mkConfiguration {
          name = "optiplexxx";
        };

        unimog = mkConfiguration {
          name = "unimog";
          modules = [
            inputs.nixos-vscode-server.nixosModules.default
            inputs.nixos-nspawn.nixosModules.hypervisor
            inputs.dnssync-rs.nixosModules.dnssync
          ];
        };

        phoenix = mkConfiguration {
          name = "phoenix";
          modules = [
            inputs.nixos-vscode-server.nixosModules.default
            inputs.dnssync-rs.nixosModules.dnssync
          ];
        };

        enderpi = outputArm.mkConfiguration {
          name = "enderpi";
          modules = [
            inputs.preservation.nixosModules.preservation
          ];
        };

        keelogspi1 = outputArm.mkConfiguration {
          name = "keelogspi1";
          modules = [
            inputs.preservation.nixosModules.preservation
            inputs.rpi-nix.nixosModules.raspberry-pi
          ];
        };

        netboot = mkConfiguration {
          name = "netboot";
          modules = [
            ({ modulesPath, ... }: {
              imports = [ "${modulesPath}/installer/netboot/netboot-minimal.nix" ];
            })
          ];
        };

        kexec = { address, prefixLength, defaultGateway, mkConf ? mkConfiguration, modules ? [] }: mkConf {
          name = "kexec";
          modules = [
            ({ modulesPath, ... }: {
              imports = [ "${modulesPath}/installer/netboot/netboot-minimal.nix" ] ++ modules;
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

        iso = mkConfiguration {
          name = "iso";
        };
      };

      nixosContainers.${system} = {
        database = mkContainer {
          name = "database";
          modules = [
            sops-nix.nixosModules.sops
          ];
        };
        email = mkContainer {
          name = "email";
          modules = [
            sops-nix.nixosModules.sops
            inputs.snm.nixosModules.mailserver
          ];
        };
        web = mkContainer {
          name = "web";
          modules = [
            sops-nix.nixosModules.sops
          ];
        };
        gaming = mkContainer {
          name = "gaming";
          modules = [
            sops-nix.nixosModules.sops
          ];
        };
        technae = mkContainer {
          name = "technae";
          modules = [
            sops-nix.nixosModules.sops
          ];
        };
        tailscale = mkContainer {
          name = "tailscale";
          modules = [
            sops-nix.nixosModules.sops
          ];
        };
        monitoring = mkContainer {
          name = "monitoring";
          modules = [
            sops-nix.nixosModules.sops
          ];
        };
        vccemail = mkContainer {
          name = "vccemail";
          modules = [
            sops-nix.nixosModules.sops
            inputs.snm.nixosModules.mailserver
          ];
        };
      };

      homeConfigurations = {
        phoenix-george = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./homes/phoenix-george ];
        };
        unimog-lucas = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./homes/unimog-lucas ];
        };
      };

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
          lib = prev.lib.extend (f: p: { "${pkgRoot}" = import ./lib/helpers.nix { inherit domain; lib = final.lib; }; });
        };
        nixos-nspawn = inputs.nixos-nspawn.overlays.default;
        imhumane-rs = inputs.imhumane-rs.overlays.imhumane-rs-nixpkgs;
        mailform-rs = inputs.mailform-rs.overlays.mailform-rs-nixpkgs;
        dnssync-rs = inputs.dnssync-rs.overlays.dnssync-rs-nixpkgs;
      };

      # Re-export nixpkgs as legacyPackages so that we can do `nix run .#<pkg name>` for any nixpkg.
      legacyPackages.${system} = pkgs;

      # Exported packages, for use in dependent flakes
      # Re-exports packages defined in overlays above
      # e.g. can be used with `nix build .#<pkgname>`
      # system and pkgs come from lib/output.nix
      packages.${system} = pkgs."${pkgRoot}" // {
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
        kexec = args: (self.nixosConfigurations.kexec args).config.system.build.kexecTree;
        home-manager = inputs.home-manager.packages.${system}.home-manager;
      };

      # Configure devShell
      # Usable with `nix develop`. shell.nix provides nix-shell compat.
      # system and pkgs come from lib/output.nix
      devShell.${system} = pkgs.mkShell {
        packages = devDeps;
      };
    };
}

{ pkgs ? import <nixpkgs> {} }:
let
  versionConfig = {
    system.nixos.versionSuffix = "pre244669.5aba0fe9766";
    system.nixos.revision = "5aba0fe9766";
  };

  mainModule = { config, lib, pkgs, ... }: {
    imports = [ ./nix-configs/configuration.nix ];
    config = {
      system.build.netbootIpxeScript = pkgs.writeTextDir "netboot.ipxe" ''
        #!ipxe
        kernel ${pkgs.stdenv.hostPlatform.platform.kernelTarget} init=${config.system.build.toplevel}/init initrd=initrd ${toString config.boot.kernelParams} boot.trace
        initrd initrd
        boot
      '';
      system.build.nixPathRegistration = pkgs.stdenv.mkDerivation {
        name = "nix_path_registration";
        buildCommand = ''
          closureInfo=${pkgs.closureInfo { rootPaths = [ config.system.build.toplevel ]; }}

          # Create a manifest for nix-store --load-db
          mkdir -p $out
          ln -s $closureInfo/registration $out/
        '';
      };
    };
  };

  configEvaled = import "${<nixpkgs>}/nixos/lib/eval-config.nix" {
    system = "x86_64-linux";
    modules = [ versionConfig mainModule ];
  };
  build = configEvaled.config.system.build;

in pkgs.symlinkJoin {
  name = "netbootos";
  paths = [
    build.initialRamdisk
    build.kernel
    build.nixPathRegistration
    build.netbootIpxeScript
  ];
  preferLocalBuild = true;
}

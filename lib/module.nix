rec {
  # Builds import paths for modules from modulesPath
  addModules = modulesPath: modules: map (mod: "${modulesPath}/${mod}") modules;

  # Imports modules in a directory
  # Used for quick building of flake.nixosModules
  # Unlike addModulesRecursive, default.nix will not collapse an entire folder,
  # instead it will be exposed as a ".default" attribute.
  importModulesRecursive = modulesPath: with builtins;
    let
      defaultNix = "${modulesPath}/default.nix";
      filterKey = "AVOID";
    in
    listToAttrs (filter (v: v != filterKey) (attrValues (mapAttrs
      (
        item: ftype:
          let
            itemPath = "${modulesPath}/${item}";
          in
          if ftype == "regular" && (match ".*\.nix$" item) != null then {
            # Take the filename without extension as the key
            name = head (match "(.*)\.nix$" (baseNameOf item));
            # Import all regular files that end in nix
            value = import itemPath;
          } else if ftype == "directory" then {
            name = item;
            # Recurse into directories
            value = importModulesRecursive itemPath;
            # Ignore everything else
          } else filterKey
      )
      (readDir modulesPath)
    )));

  # Generates importable paths for modules from a directory.
  # Assumes that default.nix files include all child nix files in a directory.
  addModulesRecursive = modulesPath:
    with builtins;
    let
      defaultNix = "${modulesPath}/default.nix";
    in
    # Return default.nix if one exists
    if pathExists defaultNix then [ defaultNix ]
    else
    # Return all regular files that end in nix
    # Recurse into directories
      concatLists (attrValues (
        mapAttrs
          (item: ftype:
            let
              itemPath = "${modulesPath}/${item}";
            in
            if ftype == "regular" && (match ".*\.nix$" item) != null then [ itemPath ]
            else if ftype == "directory" then addModulesRecursive itemPath
            else [ ]
          )
          (readDir modulesPath)
      ));
}

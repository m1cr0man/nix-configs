{ fetchurl, runCommand, php83, php84 }:
let
  # Drop OOM regression tests which do not reproduce inside the Nix build sandbox.
  mkPatchedSrc = { version, hash }:
    let
      src = fetchurl {
        url = "https://www.php.net/distributions/php-${version}.tar.bz2";
        inherit hash;
      };
    in
    runCommand "php-${version}-src" { } ''
      mkdir -p "$out"
      tar -xf ${src} -C "$out" --strip-components=1
      rm -f "$out"/ext/filter/tests/oom_filter_input.phpt \
            "$out"/ext/filter/tests/oom_filter_input_array.phpt \
            "$out"/ext/filter/tests/oom_filter_default_encoded.phpt
    '';
in
{
  php83Patched = php83.overrideAttrs(_: {
    version = "8.3.36";
    src = mkPatchedSrc {
      version = "8.3.36";
      hash = "sha256-RvS0XjaI7SsYGQFae1MsFbUcwFW907E/0A3f7r7tzV8=";
    };
  });

  php84Patched = php84.overrideAttrs(_: {
    version = "8.4.27";
    src = mkPatchedSrc {
      version = "8.4.27";
      hash = "sha256-slMKh3xyL0sIyeF0owywi6wrfhkD7m6eMV8KqfX4LCQ=";
    };
  });
}

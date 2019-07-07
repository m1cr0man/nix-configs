{ pkgs, chronografSrc }:

with import (pkgs.fetchFromGitHub {
  owner = "moretea";
  repo = "yarn2nix";
  rev = "b8d9edfd258964293ba6da552a2a6456b6239945";
  sha256 = "134f3n6bfqpv3gwpqaamnzfv2jpqx38qbis8aqllv44x9pl0xy3z";
}) { inherit pkgs; };

mkYarnPackage rec {
  name = "chronograf-ui";
  src = chronografSrc + "/ui";
  packageJson = chronografSrc + "/ui/package.json";
  yarnLock = chronografSrc + "/ui/yarn.lock";
  buildInputs = [ pkgs.git ];
  buildPhase = "yarn --offline build || cat /build/ui/deps/chronograf-ui/yarn-error.log && false";
  installPhase = "mv dist $out";
}

{ stdenvNoCC, hugo, git, openssh }:
stdenvNoCC.mkDerivation {
  name = "vcc-hugo";
  version = "1.0.0";

  src = builtins.fetchGit {
    url = "root@phoenix.vccomputers.ie:/root/vcc-hugo.git";
    name = "vcc-hugo";
    submodules = true;
    rev = "fb6ce7d7dcee9f676e8527a318e40054cd968d3f";
  };

  buildInputs = [ hugo git openssh ];

  buildPhase = ''
    hugo
  '';

  installPhase = ''
    mv dist $out
  '';
}

{ stdenvNoCC, hugo, git, openssh }:
stdenvNoCC.mkDerivation {
  name = "vcc-hugo";
  version = "1.1.0";

  src = builtins.fetchGit {
    url = "george@phoenix.vccomputers.ie:/home/george/vcc-hugo.git";
    name = "vcc-hugo";
    submodules = true;
    rev = "703787b50f303accc48710b18f16f1617099dbf6";
  };

  buildInputs = [ hugo git openssh ];

  buildPhase = ''
    hugo
  '';

  installPhase = ''
    mv dist $out
  '';
}

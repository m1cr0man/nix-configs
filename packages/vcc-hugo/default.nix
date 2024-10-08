{ stdenvNoCC, hugo, git, openssh }:
stdenvNoCC.mkDerivation {
  name = "vcc-hugo";
  version = "1.1.1";

  src = builtins.fetchGit {
    url = "george@phoenix.vccomputers.ie:/home/george/vcc-hugo.git";
    name = "vcc-hugo";
    submodules = true;
    rev = "9f77be2e66f641d904f115c98c176d98bd1d387e";
  };

  buildInputs = [ hugo git openssh ];

  buildPhase = ''
    hugo
  '';

  installPhase = ''
    mv dist $out
  '';
}

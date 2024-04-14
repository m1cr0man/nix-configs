{ stdenvNoCC, hugo, git, openssh }:
stdenvNoCC.mkDerivation {
  name = "vcc-hugo";
  version = "1.1.0";

  src = builtins.fetchGit {
    url = "george@phoenix.vccomputers.ie:/home/george/vcc-hugo.git";
    name = "vcc-hugo";
    submodules = true;
    rev = "2dbf1326da81d4e96a33fd8408ab5c88e28cdbc7";
  };

  buildInputs = [ hugo git openssh ];

  buildPhase = ''
    hugo
  '';

  installPhase = ''
    mv dist $out
  '';
}

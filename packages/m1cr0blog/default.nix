{ fetchFromGitHub, stdenvNoCC, hugo }:
stdenvNoCC.mkDerivation {
  name = "m1cr0blog";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "m1cr0man";
    repo = "m1cr0blog-hugo";
    rev = "f1815ec314fd31fd4c2488a3fef5e8b021bc8f1b";
    sha256 = "QuqD7Xq3FywhvXQxrm/WgCAg0QSDUMZpFUnczbB1CQs=";
  };

  buildInputs = [ hugo ];

  buildPhase = ''
    hugo
  '';

  installPhase = ''
    mv dist $out
  '';
}

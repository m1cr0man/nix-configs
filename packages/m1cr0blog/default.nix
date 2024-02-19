{ fetchFromGitHub, stdenvNoCC, hugo }:
stdenvNoCC.mkDerivation {
  name = "m1cr0blog";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "m1cr0man";
    repo = "m1cr0blog-hugo";
    rev = "a5639d2d2663774b92795e89523316273c7aa220";
    hash = "sha256-2qaWZ0w1L3DgaHX6k2leh9LEbyx4gaxWu/NCAKN5XTg=";
  };

  buildInputs = [ hugo ];

  buildPhase = ''
    hugo
  '';

  installPhase = ''
    mv dist $out
  '';
}

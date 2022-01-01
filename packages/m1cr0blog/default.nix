{ fetchFromGitHub, stdenvNoCC, hugo }:
stdenvNoCC.mkDerivation {
  name = "m1cr0blog";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "m1cr0man";
    repo = "m1cr0blog-hugo";
    rev = "ed15be1e58ce397f62c8750f3fa902ae6eeb405b";
    sha256 = "1s52iqmxvi96siw5xnzwb48ig32593nlfd2pf2ank7nmzsznc29g";
  };

  buildInputs = [ hugo ];

  buildPhase = ''
    hugo
  '';

  installPhase = ''
    mv dist $out
  '';
}

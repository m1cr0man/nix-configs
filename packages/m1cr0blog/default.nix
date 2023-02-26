{ fetchFromGitHub, stdenvNoCC, hugo }:
stdenvNoCC.mkDerivation {
  name = "m1cr0blog";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "m1cr0man";
    repo = "m1cr0blog-hugo";
    rev = "a44ebabeaf6e39790ac1804c4d315dec063cd8b3";
    sha256 = "e9+K3PW9jnD7BUN95xFiMLuo6iMEzJ/FMm/xeq5jnwE=";
  };

  buildInputs = [ hugo ];

  buildPhase = ''
    hugo
  '';

  installPhase = ''
    mv dist $out
  '';
}

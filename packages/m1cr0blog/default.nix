{ fetchFromGitHub, stdenvNoCC, hugo }:
stdenvNoCC.mkDerivation {
  name = "m1cr0blog";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "m1cr0man";
    repo = "m1cr0blog-hugo";
    rev = "f71bb77676ca51b66240509e6024ebdac0118186";
    sha256 = "VjRmhMkjlEh5ZYMJydRJu5utz8yUwIoqoVYpauVA5ZI=";
  };

  buildInputs = [ hugo ];

  buildPhase = ''
    hugo
  '';

  installPhase = ''
    mv dist $out
  '';
}

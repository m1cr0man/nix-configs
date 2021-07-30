{ pkgs ? import <nixpkgs> {}, buildGoModule ? pkgs.buildGoModule }:
buildGoModule {
  pname = "mc-monitor";
  version = "0.9.0";
  vendorSha256 = "0xwd8aaww93njhkizpdm5rnayba8239cxvbqjnxlciy7p7zyazpp";

  src = pkgs.fetchFromGitHub {
    owner = "itzg";
    repo = "mc-monitor";
    rev = "d54586514b4d3ae9db015c04cf982897eec5aed9";
    sha256 = "1da0cmbk6z169msvfacwxj42awz1hq5g0gw34fzng0wpmihidas6";
    fetchSubmodules = true;
  };
}

{
  lib,
  fetchFromGitHub,
  libcamera,
  boost,
  nlohmann_json,
  python3Packages,
  git,
  cacert,
  meson,
}:
libcamera.overrideAttrs (old: {
  buildInputs = old.buildInputs ++ [ boost nlohmann_json ];
  nativeBuildInputs = old.nativeBuildInputs ++ [ python3Packages.pybind11 ];

  BOOST_INCLUDEDIR = "${lib.getDev boost}/include";
  BOOST_LIBRARYDIR = "${lib.getLib boost}/lib";

  postPatch = old.postPatch + ''
    patchShebangs src/py/libcamera
  '';

  mesonFlags = old.mesonFlags ++ [
    "-Dcam=disabled"
    "-Dgstreamer=disabled"
    "-Dipas=rpi/vc4,rpi/pisp"
    "-Dpipelines=rpi/vc4,rpi/pisp"
  ];

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "libcamera";
    rev = "29156679717bec7cc4784aeba3548807f2c27fca";
    hash = "sha256-T+o9p57te13IGXqOamVMVGKerMVbixUIzcSpm7GlMj4=";

    nativeBuildInputs = [ git ];

    postFetch = ''
      cd "$out"

      export NIX_SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt

      ${lib.getExe meson} subprojects download \
        libpisp

      find subprojects -type d -name .git -prune -execdir rm -r {} +
    '';
  };
})

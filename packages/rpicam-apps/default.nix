{ stdenv
, callPackage
, fetchFromGitHub
, lib
, makeWrapper
, meson
, ninja
, pkg-config
, boost
, ffmpeg-headless
, libdrm
, libepoxy
, libexif
, libjpeg
, libpng
, libtiff
, libX11
}:
let
  libcamera-rpi = callPackage (import ../libcamera-rpi) {};
in
stdenv.mkDerivation (finalAttrs: {
  pname = "rpicam-apps";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "rpicam-apps";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pTSHmRmGV203HjrH6MWNDEz2xLitCsILKsOYD9PgjwU=";
  };

  buildInputs = [
    boost
    ffmpeg-headless
    libcamera-rpi
    libdrm
    libepoxy # GLES/EGL preview window
    libexif
    libjpeg
    libpng
    libtiff
    libX11
  ];

  nativeBuildInputs = [
    makeWrapper
    meson
    ninja
    pkg-config
  ];

  # See all options here: https://github.com/raspberrypi/rpicam-apps/blob/main/meson_options.txt
  mesonFlags = [
    "-Denable_drm=disabled"
    "-Denable_egl=disabled"
    "-Denable_hailo=disabled"
    "-Denable_qt=disabled"
    "-Denable_libav=disabled"
  ];

  postInstall = ''
    for f in rpicam-hello rpicam-jpeg rpicam-raw rpicam-still rpicam-vid
    do
      wrapProgram $out/bin/$f --set-default LIBCAMERA_IPA_PROXY_PATH ${libcamera-rpi}/libexec/libcamera
    done
  '';
})

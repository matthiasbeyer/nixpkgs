{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  SDL2,
  fftw,
  gtest,
  eigen,
  libepoxy,
  libGL,
  libX11,
}:

stdenv.mkDerivation rec {
  pname = "movit";
  version = "1.7.1";

  src = fetchurl {
    url = "https://movit.sesse.net/${pname}-${version}.tar.gz";
    sha256 = "sha256-szBztwXwzLasSULPURUVFUB7QLtOmi3QIowcLLH7wRo=";
  };

  outputs = [
    "out"
    "dev"
  ];

  GTEST_DIR = "${gtest.src}/googletest";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    SDL2
    fftw
    gtest
    libGL
    libX11
  ];

  propagatedBuildInputs = [
    eigen
    libepoxy
  ];

  env = {
    NIX_CFLAGS_COMPILE = "-std=c++17"; # needed for latest gtest
  }
  // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_LDFLAGS = "-framework OpenGL";
  };

  enableParallelBuilding = true;

  meta = with lib; {
    description = "High-performance, high-quality video filters for the GPU";
    homepage = "https://movit.sesse.net";
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}

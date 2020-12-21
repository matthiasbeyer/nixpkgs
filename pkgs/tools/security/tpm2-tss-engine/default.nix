{ stdenv
, fetchFromGitHub
, lib
, pkg-config
, makeWrapper
, curl
, openssl
, tpm2-tss
}:

stdenv.mkDerivation rec {
  pname = "tpm2-tss-engine";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "tpm2-software";
    repo = pname;
    rev = "v${version}";
    sha256 = "1pwc38izkk50s73xzcca1l5h265lmh4hcgpfq8lmbv5grq2qdal8";
  };

  nativeBuildInputs = [ pkg-config makeWrapper ];
  buildInputs = [
    curl openssl tpm2-tss
  ];

  #preFixup = let
  #  ldLibraryPath = lib.makeLibraryPath ([
  #    tpm2-tss
  #  ];
  #in ''
  #  for bin in $out/bin/*; do
  #    wrapProgram $bin \
  #      --suffix LD_LIBRARY_PATH : "${ldLibraryPath}"
  #  done
  #'';

  meta = with lib; {
    description = "OpenSSL Engine for TPM2 devices";
    homepage = "tpm2-software.github.io";
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ matthiasbeyer ];
  };
}


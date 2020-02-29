{ stdenv
, rustPlatform
, fetchFromGitHub
, llvmPackages
, openssl
, pkg-config
, Security
}:

rustPlatform.buildRustPackage rec {
  pname = "imag";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "matthiasbeyer";
    repo = pname;
    rev = "v${version}";
    sha256 = "0f9915f083z5qqcxyavj0w6m973c8m1x7kfb89pah5agryy5mkaq";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ]
    ++ stdenv.lib.optional stdenv.isDarwin Security;

  LIBCLANG_PATH = "${llvmPackages.libclang}/lib";

  cargoSha256 = "0n8cw70qh8g4hfwfaxwwxbrrx5hm2z037z8kdhvdpqkxljl9189x";

  checkPhase = ''
    cargo test -- \
    --skip test_linking
  '';

  meta = with stdenv.lib; {
    description = "Commandline personal information management suite";
    homepage = "https://imag-pim.org/";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ filalex77 ];
    platforms = platforms.unix;
  };
}

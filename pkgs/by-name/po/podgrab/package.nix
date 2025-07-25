{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

buildGoModule {
  pname = "podgrab";
  version = "0-unstable-2021-04-14";

  src = fetchFromGitHub {
    owner = "akhilrex";
    repo = "podgrab";
    rev = "3179a875b8b638fb86d0e829d12a9761c1cd7f90";
    sha256 = "sha256-vhxIm20ZUi+RusrAsSY54tv/D570/oMO5qLz9dNqgqo=";
  };

  vendorHash = "sha256-xY9xNuJhkWPgtqA/FBVIp7GuWOv+3nrz6l3vaZVLlIE=";

  postInstall = ''
    mkdir -p $out/share/
    cp -r $src/client $out/share/
    cp -r $src/webassets $out/share/
  '';

  passthru.tests = { inherit (nixosTests) podgrab; };

  meta = with lib; {
    description = "Self-hosted podcast manager to download episodes as soon as they become live";
    mainProgram = "podgrab";
    homepage = "https://github.com/akhilrex/podgrab";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ambroisie ];
  };
}

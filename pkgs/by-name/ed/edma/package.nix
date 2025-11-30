{
  lib,
  rustPlatform,
  fetchFromGitHub,
  llvmPackages,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "edma";
  version = "0.1.0-beta.5";

  src = fetchFromGitHub {
    owner = "chungquantin";
    repo = "edma";
    rev = "v${version}";
    hash = "sha256-IhzvEGlkUy6B9IWrwDrVtOFCtfim5KUxq+9fa+ef81c=";
  };

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  depsBuildBuild = [ pkg-config ];

  cargoHash = "sha256-td9zdmmKOA4CP+LmInzWaDJqUZpLo1lLsBUChNIkPao=";

  meta = {
    description = "EDMA is an interactive terminal app for managing multiple embedded databases system at once with powerful byte deserializer support";
    homepage = "https://github.com/chungquantin/edma";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      matthiasbeyer
    ];
    mainProgram = "edma";
  };
}

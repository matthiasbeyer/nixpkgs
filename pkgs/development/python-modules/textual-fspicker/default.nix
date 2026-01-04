{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  uv-build,
  textual,
  setuptools,
}:

buildPythonPackage rec {
  pname = "textual-fspicker";
  version = "0.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "davep";
    repo = "textual-fspicker";
    tag = "v${version}";
    hash = "sha256-vfIPZvpYN56WdO/OQ/jvc40jY8cwU26nDLVPC4IqeoE=";
  };

  buildInputs = [ setuptools uv-build ];

  build-system = [ uv-build ];

  dependencies = [
    textual
  ];

  nativeBuildInputs = [
    uv-build
  ];

  pythonImportsCheck = [ "textual_fspicker" ];

  doCheck = true;

  meta = {
    description = "A Textual widget library for picking things in the filesystem";
    homepage = "https://github.com/davep/textual-fspicker/";
    changelog = "https://github.com/davep/textual-fspicker/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      matthiasbeyer
    ];
  };
}

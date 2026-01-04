{
  lib,
  fetchFromGitea,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "tooi";
  version = "0.17.0";
  pyproject = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "ihabunek";
    repo = "tooi";
    tag = version;
    hash = "sha256-cZVNeEm44q6fhzwDxQLtC8bZiihG1yCzOn0FVu32yTk=";
  };

  nativeCheckInputs = with python3Packages; [ pytest ];

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    aiodns
    aiohttp
    beautifulsoup4
    click
    html2text
    pillow
    platformdirs
    pydantic
    textual
    textual-fspicker
    textual-image
    tomlkit
  ];

  meta = {
    description = "tooi is a text-based user interface for Mastodon, Pleroma and friends";
    mainProgram = "tooi";
    homepage = "https://codeberg.org/ihabunek/tooi";
    changelog = "https://codeberg.org/ihabunek/tooi/blob/refs/tags/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      matthiasbeyer
    ];
  };
}


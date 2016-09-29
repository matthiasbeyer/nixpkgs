{ stdenv, fetchFromGitHub, python3Packages }:

stdenv.mkDerivation rec {
  name = "bean-add-2016-09-29";

  src = fetchFromGitHub {
    owner = "simon-v";
    repo = "bean-add";
    rev = "76945c320e6f028223e4420956c80c421c4fe74a";
    sha256 = "0dslzaimfwqvwz4z1qlmjvr5gklfd9n6hbsghl375ndfj8qgql1y";
  };

  buildInputs = [ python3Packages.wrapPython ];

  propagatedBuildInputs = with python3Packages; [ readline ];

  installPhase = ''
    mkdir -p $out/bin/
    cp bean-add $out/bin/bean-add
    chmod +x $out/bin/bean-add
    wrapPythonProgram $out/bin/bean-add
  '';

  meta = {
    homepage = https://github.com/simon-v/bean-add/;
    description = "beancount transaction entry assistant";

    # The (only) source file states:
    #   License: "Do what you feel is right, but don't be a jerk" public license.

    maintainers = with stdenv.lib.maintainers; [ matthiasbeyer ];
  };
}


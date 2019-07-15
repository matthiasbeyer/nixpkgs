{ stdenv
, fetchFromGitHub
, pkgconfig
, fontconfig
, wayland
, libxkbcommon
, pixman
, libdrm
, ncurses
, writeText
, conf ? null
, patches ? []
, extraLibs ? []}:

with stdenv.lib;

stdenv.mkDerivation rec {
  name    = "wterm";
  version = "0ae42717c08a85a6509214e881422c7fbe7ecc45";
  pname   = "${name}-${version}";

  src = fetchFromGitHub {
    owner  = "majestrate";
    repo   = name;
    rev    = version;
    sha256 = "0g4lzmc1w6na81i6hny32xds4xfig4xzswzfijyi6p93a1226dv0";
  };

  inherit patches;

  configFile = optionalString (conf!=null) (writeText "config.def.h" conf);
  preBuild = optionalString (conf!=null) "cp ${configFile} config.def.h";

  nativeBuildInputs = [ pkgconfig fontconfig ncurses ];
  buildInputs = [
    wayland
    libxkbcommon
    pixman
    libdrm
  ] ++ extraLibs;

  installPhase = ''
    PREFIX=$out TERMINFO=$out/share/terminfo make install
  '';

  outputs = [ "out" "terminfo" ];

  meta = {
    homepage = https://github.com/majestrate/wterm;
    description = "st fork for wayland";
    license = licenses.mit;
    maintainers = with maintainers; [ matthiasbeyer ];
    platforms = platforms.linux;
  };
}

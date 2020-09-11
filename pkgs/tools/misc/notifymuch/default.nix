{ lib, python3Packages, fetchFromGitHub, glibcLocales }:

with python3Packages;
buildPythonApplication rec {
  pname = "notifymuch";
  version = "2020-09-11";

  src = fetchFromGitHub {
    owner = "kspi";
    repo = "notifymuch";
    rev = "9d4aaf54599282ce80643b38195ff501120807f0";
    sha256 = "1lssr7iv43mp5v6nzrfbqlfzx8jcc7m636wlfyhhnd8ydd39n6k4";
  };

  checkInputs = [ pygobject3 notmuch notify2 ];

  meta = {
    description = "Display desktop notifications for unread mail in notmuch database";
    homepage = "https://github.com/kspi/notifymuch";
    # license = # no license in repository
  };
}



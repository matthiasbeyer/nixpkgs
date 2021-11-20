{ callPackage, lib, stdenv, fetchurl, gmp }:

callPackage ./generic.nix rec {
  version = "0.14.1";
  urls = [
    "mirror://sourceforge/libisl/libisl-${version}.tar.xz"
    "https://libisl.sourceforge.io/libisl-${version}.tar.xz"
  ];
  sha256 = "0xa6xagah5rywkywn19rzvbvhfvkmylhcxr6z9z7bz29cpiwk0l8";
  homepage = "https://www.kotnet.org/~skimo/isl/";
}


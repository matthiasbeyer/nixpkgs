{ callPackage, lib, stdenv, fetchurl, gmp }:

callPackage ./generic.nix rec {
  version = "0.24";
  urls = [
    "mirror://sourceforge/libisl/libisl-${version}.tar.xz"
    "https://libisl.sourceforge.io/libisl-${version}.tar.xz"
  ];
  sha256 = "1ak1gq0rbqbah5517blg2zlnfvjxfcl9cjrfc75nbcx5p2gnlnd5";
  homepage = "https://sourceforge.net/projects/libisl/";
} // {
  configureFlags = [
    "--with-gcc-arch=generic" # don't guess -march=/mtune=
  ];
}


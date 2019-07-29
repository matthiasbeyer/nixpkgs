{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  brand = "Midas";
  type = "M32";
  version = "3.2";
  sha256 = "1cds6qinz37086l6pmmgrzrxadygjr2z96sjjyznnai2wz4z2nrd";
})

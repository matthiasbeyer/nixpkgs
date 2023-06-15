{ linkFarm, fetchurl }:
{ name, nugetDeps ? import sourceFile, sourceFile ? null }:
linkFarm "${name}-nuget-deps" (nugetDeps {
  fetchNuGet =
    { pname
    , version
    , sha256
    , url ? "https://www.nuget.org/api/v2/package/${pname}/${version}"
    }:
    {
      name = "${pname}.${version}.nupkg";
      inherit url sha256;
      path = builtins.fetchurl { inherit url sha256; };
    };
}) // {
  inherit sourceFile;
}

{ linkFarm, fetchurl }:
{ name, nugetDeps ? import sourceFile, sourceFile ? null }:
linkFarm "${name}-nuget-deps" (nugetDeps {
  fetchNuGet =
    { pname
    , version
    , hash ? null
    , sha256 ? null
    , url ? "https://www.nuget.org/api/v2/package/${pname}/${version}"
    }:
    let
      sha = if (builtins.isNull hash) then
        sha256
      else
        hash;
    in
    {
      name = "${pname}.${version}.nupkg";
      inherit url;
      sha256 = sha;
      path = builtins.fetchurl {
        inherit url;
        sha256 = sha;
      };
    };
}) // {
  inherit sourceFile;
}

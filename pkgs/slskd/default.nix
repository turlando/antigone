{ pkgs, lib, fetchFromGitHub, buildDotnetModule }:

# To generate the deps.nix file
# nix-build -E "with import <nixpkgs> {}; callPackage ./default.nix {}" -A passthru.fetch-deps
# ./result
#
# To build
# nix-build -E "with import <nixpkgs> {}; callPackage ./default.nix {}"

let
  name = "slskd";
  version = "0.17.5";
in
buildDotnetModule {
  pname = name;
  baseName = name;
  version = version;
  src = fetchFromGitHub {
    owner = name;
    repo = name;
    rev = version;
    sha256 = "sha256-iIM29ZI3M9etbw4yzin+4f4cGHIt5qjIl7uzsTUCBc4=";
  };
  dotnet-sdk = pkgs.dotnet-sdk_7;
  dotnet-runtime = pkgs.dotnet-aspnetcore_7;
  projectFile = "src/slskd/slskd.csproj";
  testProjectFile = "tests/slskd.Tests.Unit/slskd.Tests.Unit.csproj";
  doCheck = true;
  nugetDeps = ./deps.nix;
  meta = {
    homepage = "https://github.com/${name}/${name}";
    description = "A modern client-server application for the Soulseek file sharing network.";
    license = lib.licenses.agpl3;
  };
}

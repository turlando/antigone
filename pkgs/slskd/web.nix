{ lib, buildNpmPackage, fetchFromGitHub }:

let
  version = "0.17.5";

  src = fetchFromGitHub {
    owner = "slskd";
    repo = "slskd";
    rev = version;
    sha256 = "sha256-iIM29ZI3M9etbw4yzin+4f4cGHIt5qjIl7uzsTUCBc4=";
  };
in
buildNpmPackage {
  pname = "slskd-web";
  version = version;
  src = "${src}/src/web";
  npmDepsHash = "sha256-ki7FPGu0FNVrshLbHDYQ0LE6xXn34wncKUEH8nfnIfg=";
  meta = {
    license = lib.licenses.agpl3;
  };
}

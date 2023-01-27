{ pkgs, ... }:

# nix-build -E "with import <nixpkgs> {}; callPackage ./default.nix {}"

pkgs.stdenv.mkDerivation {
  pname = "telegram-send";
  version = "0.0.1";
  buildInputs = [ (pkgs.python311.withPackages (ps: [])) ];
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    cp ${./telegram-send.py} $out/bin/telegram-send
    chmod +x $out/bin/telegram-send
  '';
}

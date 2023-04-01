{ pkgs, ... }:

{
  telegram-send = pkgs.callPackage ./telegram-send {};
  slskd = pkgs.callPackage ./slskd {};
}

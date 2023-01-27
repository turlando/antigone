{ pkgs, ... }:

{
  telegram-send = pkgs.callPackage ./telegram-send {};
}

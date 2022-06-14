{ pkgs, ... }:

{
  imports = [
    ./system
    ./services
  ];

  system.stateVersion = "20.03";
  _module.args.util = import ./util.nix {};
}

{ pkgs, ... }:

{
  imports = [
    ./system
    ./services
  ];

  system.stateVersion = "20.03";
  _module.args.utils = import ./utils.nix {};
}

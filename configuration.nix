{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./system
  ];

  system.stateVersion = "22.11";
  _module.args.util = import ./util.nix {};
}

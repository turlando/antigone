args@{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./system
  ];

  _module.args.util = import ./util.nix args;

  system.stateVersion = "22.11";
}

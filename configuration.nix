{ pkgs, ... }@args:

{
  _module.args.localLib = import ./lib args;
  _module.args.localPkgs = import ./pkgs args;

  imports = [ ./config ];

  system.stateVersion = "22.11";
}

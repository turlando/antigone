{ pkgs, ... }@args:

{
  _module.args.util = import ./util.nix args;
  _module.args.localPkgs = import ./packages args;

  imports = [ ./configuration ];
}

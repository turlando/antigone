args@{ pkgs, ... }:

{
  imports = [ ./configuration ];
  _module.args.util = import ./util.nix args;
}

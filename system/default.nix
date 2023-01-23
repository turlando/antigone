{ ... }:

{
  imports = [
    ./booting.nix
    ./network.nix
    ./users.nix
    ./packages.nix
    ./daemons.nix
  ];
}

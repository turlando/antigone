{ ... }:

{
  imports = [
    ./options.nix
    ./configuration.nix

    ./booting.nix
    ./network.nix
    ./users.nix
    ./packages.nix
    ./daemons.nix
  ];
}

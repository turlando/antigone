{ ... }:

{
  imports = [
    ./options.nix
    ./configuration.nix

    ./booting.nix
    ./filesystems.nix
    ./network.nix
    ./users.nix
    ./daemons.nix
    ./packages.nix
  ];
}

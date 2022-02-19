{ ... }:

{
  imports = [
    ./booting.nix
    ./filesystems.nix
    ./network.nix
    ./users.nix
    ./packages.nix
    ./daemons.nix
  ];
}

{ ... }:

{
  imports = [
    ./booting.nix
    ./storage.nix
    ./network.nix
    ./users.nix
    ./packages.nix
    ./alerting.nix

    ./services
  ];
}

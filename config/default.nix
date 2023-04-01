{ ... }:

{
  imports = [
    ./hardware.nix
    ./booting.nix
    ./storage.nix
    ./network.nix
    ./users.nix
    ./packages.nix
    ./alerting.nix

    ./services
  ];
}

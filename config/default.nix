{ ... }:

{
  imports = [
    ./hardware.nix
    ./booting.nix
    ./storage.nix
    ./network.nix
    ./users.nix
    ./packages.nix
    ./virtualisation.nix
    ./alerting.nix

    ./services
  ];
}

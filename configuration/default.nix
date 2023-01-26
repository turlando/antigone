{ ... }:

{
  system.stateVersion = "22.11";

  imports = [
    ./options.nix
    ./configuration.nix

    ./hardware-configuration.nix

    ./booting.nix
    ./storage.nix
    ./network.nix
    ./users.nix
    ./daemons.nix
    ./packages.nix
    ./monitoring.nix

    ./services
  ];
}

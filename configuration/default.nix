{ ... }:

{
  system.stateVersion = "22.11";

  imports = [
    ./options.nix
    ./configuration.nix

    ./hardware-configuration.nix

    ./booting.nix
    ./filesystems.nix
    ./network.nix
    ./users.nix
    ./daemons.nix
    ./packages.nix

    ./services
  ];
}

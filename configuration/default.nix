{ ... }:

{
  system.stateVersion = "22.11";

  imports = [
    ./hardware-configuration.nix

    ./booting.nix
    ./users.nix
    ./daemons.nix
    ./packages.nix
    ./monitoring.nix
  ];
}

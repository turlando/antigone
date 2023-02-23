{ ... }@args:

{
  attrsets = import ./attrsets.nix args;
  files = import ./files.nix args;
  filesystems = import ./filesystems.nix args;
  services = import ./services.nix args;
}

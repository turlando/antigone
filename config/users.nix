{ config, pkgs, lib, localLib, ... }:

let
  inherit (localLib.attrsets) getNames mergeAttrsets;
  inherit (localLib.files) getSshKey readPassword;
  inherit (localLib.filesystems) homeFileSystem;

  inherit (config.users) groups;

  root = {
    hashedPassword = readPassword "tancredi";
    openssh.authorizedKeys.keyFiles = [ (getSshKey "tancredi") ];
  };

  users = {
    tancredi = {
      isNormalUser = true;
      hashedPassword = readPassword "tancredi";
      shell = pkgs.zsh;
      extraGroups = [
        groups.wheel.name
        groups.storage.name
      ];
      openssh.authorizedKeys.keyFiles = [ (getSshKey "tancredi") ];
    };
  };

  # TODO: maybe move this to storage.nix?
  # We have to filter config.users.users for isNormalUser == true
  # and map homeFileSystem over the users' names.
  filesystems = mergeAttrsets (map homeFileSystem (getNames users));
in
{
  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults lecture="never"
    '';
  };

  fileSystems = filesystems;

  users = {
    mutableUsers = false;
    users = mergeAttrsets [ { root = root; } users ];
  };
}

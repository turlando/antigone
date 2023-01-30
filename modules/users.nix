{ config, pkgs, lib, localLib, ... }:

let
  inherit (localLib.attrsets) getNames mergeAttrsets;
  inherit (localLib.files) getSshKey readPassword;
  inherit (localLib.filesystems) homeFileSystem;

  root = {
    hashedPassword = readPassword "tancredi";
    openssh.authorizedKeys.keyFiles = [ (getSshKey "tancredi") ];
  };

  users = {
    tancredi = {
      isNormalUser = true;
      hashedPassword = readPassword "tancredi";
      shell = pkgs.zsh;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keyFiles = [ (getSshKey "tancredi") ];
    };
  };

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

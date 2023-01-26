{ config, pkgs, localLib, ... }:

let
  inherit (localLib.files) getSshKey readPassword;
in
{
  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults lecture="never"
    '';
  };

  users = {
    mutableUsers = false;

    users = {
      root = {
        hashedPassword = readPassword "tancredi";
        openssh.authorizedKeys.keyFiles = [ (getSshKey "tancredi") ];
      };

      tancredi = {
        isNormalUser = true;
        hashedPassword = readPassword "tancredi";
        shell = pkgs.zsh;

        extraGroups = [
          "wheel"
        ];

        openssh.authorizedKeys.keyFiles = [ (getSshKey "tancredi") ];
      };
    };
  };
}

{ config, pkgs, util, ... }:

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
        hashedPassword = util.readPassword "tancredi";
        openssh.authorizedKeys.keyFiles = [ (util.getSshKey "tancredi") ];
      };

      tancredi = {
        isNormalUser = true;
        hashedPassword = util.readPassword "tancredi";
        shell = pkgs.zsh;

        extraGroups = [
          "wheel"
        ];

        openssh.authorizedKeys.keyFiles = [ (util.getSshKey "tancredi") ];
      };
    };
  };
}

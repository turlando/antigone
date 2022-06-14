{ config, pkgs, util, ... }:

{
  security.sudo.enable = true;

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;

    users = {
      root = {
        hashedPassword = util.readPassword "tancredi";
        openssh.authorizedKeys.keyFiles = [ (util.getSshKey "tancredi") ];
      };

      tancredi = {
        isNormalUser = true;
        hashedPassword = util.readPassword "tancredi";
        openssh.authorizedKeys.keyFiles = [ (util.getSshKey "tancredi") ];

        extraGroups = [
          "wheel"
          config.users.groups.storage.name
        ];
      };
    };
  };
}

{ config, pkgs, utils, ... }:

{
  security.sudo.enable = true;

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;

    users = {
      root = {
        hashedPassword = utils.readPassword "tancredi";
        openssh.authorizedKeys.keyFiles = [ (utils.getSshKey "tancredi") ];
      };

      tancredi = {
        isNormalUser = true;
        hashedPassword = utils.readPassword "tancredi";
        openssh.authorizedKeys.keyFiles = [ (utils.getSshKey "tancredi") ];

        extraGroups = [
          "wheel"
          config.users.groups.storage-books.name
        ];
      };
    };
  };
}

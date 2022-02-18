{ config, pkgs, utils, ... }:

let

  # type: string -> path
  getKey = user: utils.getFile (/ssh-keys + "/${user}.pub");

  # type: string -> string
  getPassword = user: utils.readFile (/hashed-passwords + "/${user}.txt");

in

{
  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;

    users = {
      root = {
        hashedPassword = getPassword "tancredi";
        openssh.authorizedKeys.keyFiles = [ (getKey "tancredi") ];
      };

      tancredi = {
        isNormalUser = true;
        hashedPassword = getPassword "tancredi";
        openssh.authorizedKeys.keyFiles = [ (getKey "tancredi") ];

        extraGroups = [
          "wheel"
          config.users.groups.storage-books.name
        ];
      };
    };
  };
}

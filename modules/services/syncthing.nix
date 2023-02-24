{ config, localLib, ... }:

let
  inherit (localLib.attrsets) mergeAttrsets;
  inherit (localLib.filesystems) serviceFileSystem servicePath;
  inherit (localLib.services) dataPath resolvBindMount dataBindMount hostBindMount;

  name = "syncthing";

  storageConfig = config.local.storage;
  storageGroup = config.users.groups.storage;
in
{
  fileSystems = mergeAttrsets [
    (serviceFileSystem name)
  ];

  containers."${name}" = {
    ephemeral = true;
    autoStart = true;

    bindMounts = mergeAttrsets [
      resolvBindMount
      (dataBindMount name)
      (hostBindMount storageConfig.paths.books)
    ];

    config =
      { config, pkgs, ... }:
      {
        system.stateVersion = "22.11";

        users.groups = {
          storage = storageGroup;
        };

        users.users.syncthing = {
          extraGroups = [ storageGroup.name ];
        };

        services.syncthing = {
          enable = true;
          configDir = toString dataPath;
          guiAddress = "127.0.0.1:8383";
        };
      };
  };
}

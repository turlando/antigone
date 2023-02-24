{ config, localLib, ... }:

let
  inherit (localLib.attrsets) mergeAttrsets;
  inherit (localLib.filesystems) serviceFileSystem servicePath;
  inherit (localLib.services) dataPath resolvBindMount dataBindMount hostBindMount;

  name = "syncthing";

  storageConfig = config.local.storage;
  storageGroup = config.users.groups.storage;

  antigoneId = "6YAFIOP-Y6TGT4V-FPT77ER-YZMJODJ-533JSKV-FJ5IFOW-QNVMVAV-32XR6AR";
  bahnhofId = "USBCMJL-WXMG4PP-XC364HB-OKBWEVH-HGKVW6E-T2YML7O-56BMQMH-3P7BUAP";
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

          devices = {
            Antigone.id = antigoneId;
            Bahnhof.id = bahnhofId;
          };

          folders = {
            books = {
              label = "Books";
              path = toString storageConfig.paths.books;
              type = "sendonly";
              devices = [
                config.services.syncthing.devices.Bahnhof.name
              ];
            };
          };
        };
      };
  };
}

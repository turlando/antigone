{ config, ... }:

{
  fileSystems."/srv/syncthing" =
    { device = "fast-storage/services/syncthing";
      fsType = "zfs";
    };

  containers.syncthing =
    { autoStart = true;

      bindMounts =
        { "/data" =
            { hostPath = "/srv/syncthing";
              isReadOnly = false;
            };
          "/mnt/storage/books" =
            { hostPath = "/mnt/storage/books";
              isReadOnly = false;
            };
        };

      config =
        { ... }:
        { system.stateVersion = "21.11";

          users.groups =
            { storage-books = config.users.groups.storage-books;
            };

          users.users.syncthing =
            { extraGroups = [ config.users.groups.storage-books.name ];
            };

          system.activationScripts.data-permissions =
            { text =
              ''
              chown syncthing /data
              chown syncthing /mnt/storage/books
              '';
              deps = [ "users" "groups" ];
            };

          services.syncthing =
            { enable = true;
              dataDir = "/data/data";
              configDir = "/data/config";
              # guiAddress does not work because it's passing
              # `-gui-address' instead of `--gui-address'.
              # guiAddress = "127.0.0.1:8383";
              extraFlags = [ "--no-browser" "--gui-address=127.0.0.1:8383" ];
            };
        };
    };
}

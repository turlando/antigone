{ config, ... }:

{
  users.groups.storage-books =
    { gid = 5001;
    };

  system.activationScripts.mnt-storage-books =
    { text =
      ''
      if [ ! -d /mnt/storage/books ]; then
        mkdir /mnt/storage/books
      fi
      chown nobody:storage-books /mnt/storage/books
      '';
      deps = [ "users" "groups" ];
    };

  fileSystems."/mnt/storage/books" =
    { device = "large-storage/books";
      fsType = "zfs";
    };
}

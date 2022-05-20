{ config, ... }:

{
  users.groups.storage = { gid = 5000; };

  fileSystems = {
    "/mnt/storage/books" =
      { device = "large-storage/books";
        fsType = "zfs";
      };
  };
}

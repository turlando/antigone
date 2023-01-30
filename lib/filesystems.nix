{ config, ... }:

rec {
  # type: int -> AttrSet
  bootFileSystem = index: {
    "/boot/${toString index}" = {
      device = "/dev/disk/by-partlabel/boot-${toString index}";
      fsType = "ext4";
    };
  };

  # type: str -> str -> str -> AttrSet
  zfsFileSystem = pool: filesystem: mountPoint: {
    "${mountPoint}" = {
      device = "${pool}/${filesystem}";
      fsType = "zfs";
    };
  };

  # type: str -> AttrSet
  zfsFileSystem' = dataset: mountPoint: {
    "${mountPoint}" = {
      device = dataset;
      fsType = "zfs";
    };
  };

  # type: str -> str
  serviceFileSystem =
    name: zfsFileSystem'
      "${config.local.storage.datasets.services}/${name}"
      (toString config.local.storage.paths.services + "/${name}");

  # type: str -> path
  servicePath = name: config.local.storage.paths.services + "/${name}";
}

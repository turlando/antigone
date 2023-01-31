{ config, ... }:

rec {
  # type: int -> AttrSet
  bootFileSystem = index: {
    "/boot/${toString index}" = {
      device = "/dev/disk/by-partlabel/boot-${toString index}";
      fsType = "ext4";
      options = [ "nofail" ];
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

  # type: str -> AttrSet
  homeFileSystem =
    name: zfsFileSystem'
      "${config.local.storage.datasets.home}/${name}"
      "/home/${name}";

  # type: str -> AttrSet
  serviceFileSystem =
    name: zfsFileSystem'
      "${config.local.storage.datasets.services}/${name}"
      (toString config.local.storage.paths.services + "/${name}");

  # type: str -> path
  servicePath = name: config.local.storage.paths.services + "/${name}";
}

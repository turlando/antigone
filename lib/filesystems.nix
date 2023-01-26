{ ... }:

{
  # type: int -> AttrSet
  bootFileSystem = index: {
    "/boot/${toString index}" = {
      device = "/dev/disk/by-partlabel/boot-${toString index}";
      fsType = "ext4";
    };
  };

  # type: str -> str -> str -> AttrSet
  zfsFileSystem = pool: dataset: mountPoint: {
    "${mountPoint}" = {
      device = "${pool}/${dataset}";
      fsType = "zfs";
    };
  };
}

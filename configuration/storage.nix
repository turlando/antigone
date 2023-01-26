{ config, util, ... }:

let

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

  bootFileSystems = util.mergeAttrsets (map bootFileSystem [ 1 2 ]);

  systemFileSystems = util.mergeAttrsets [
    (zfsFileSystem "system" "root" "/")
    (zfsFileSystem "system" "nix" "/nix")
    (zfsFileSystem "system" "state" config.system.statePath)
    (zfsFileSystem "system" "home/tancredi" "/home/tancredi")
  ];

in

{
  fileSystems = util.mergeAttrsets [ bootFileSystems systemFileSystems ];
}

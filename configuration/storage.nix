{ config, lib, util, ... }:

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

  bootFileSystems =
    let
        count = builtins.length config.system.systemDrives;
        range = lib.range 1 count;
    in
      util.mergeAttrsets (map bootFileSystem range);

  systemFileSystems = util.mergeAttrsets [
    (zfsFileSystem "system" "root" "/")
    (zfsFileSystem "system" "nix" "/nix")
    (zfsFileSystem "system" "state" (toString config.system.statePath))
    (zfsFileSystem "system" "home/tancredi" "/home/tancredi")
  ];

in

{
  fileSystems = util.mergeAttrsets [ bootFileSystems systemFileSystems ];

  services.zfs.autoScrub = {
    enable = true;
    # Run on the first Sunday of every month at 02:00.
    interval = "Mon *-*-1..7 02:00:00";
  };

  services.zfs.trim = {
    enable = true;
    # Run on every Friday at 02:00.
    interval = "Fri *-*-* 02:00:00";
  };
}

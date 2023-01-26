{ config, lib, localLib, ... }:

let
  inherit (builtins) length;
  inherit (lib) range;
  inherit (localLib.attrsets) mergeAttrsets;
  inherit (localLib.filesystems) bootFileSystem zfsFileSystem;

  systemDrives = config.system.systemDrives;
  statePath = toString config.system.statePath;

  bootFileSystems =
    let
        drivesCount = length systemDrives;
        drivesRange = range 1 drivesCount;
    in
      mergeAttrsets (map bootFileSystem drivesRange);

  systemFileSystems = mergeAttrsets [
    (zfsFileSystem "system" "root" "/")
    (zfsFileSystem "system" "nix" "/nix")
    (zfsFileSystem "system" "state" statePath)
    (zfsFileSystem "system" "home/tancredi" "/home/tancredi")
  ];
in
{
  fileSystems = mergeAttrsets [ bootFileSystems systemFileSystems ];

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

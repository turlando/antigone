{ config, lib, localLib, ... }:

let
  inherit (builtins) length;
  inherit (lib) mkAfter mkIf range types;
  inherit (localLib.attrsets) mergeAttrsets;
  inherit (localLib.filesystems) bootFileSystem zfsFileSystem;

  cfg = config.local.storage;

  systemDrives = map toString cfg.systemDrives;
  systemPool = cfg.systemPool;
  ephemeralRoot = cfg.ephemeralRoot;
  statePath = toString cfg.statePath;

  bootFileSystems =
    let
      drivesCount = length systemDrives;
      drivesRange = range 1 drivesCount;
    in
      mergeAttrsets (map bootFileSystem drivesRange);

  systemFileSystems = mergeAttrsets [
    (zfsFileSystem systemPool "root" "/")
    (zfsFileSystem systemPool "nix" "/nix")
    (zfsFileSystem systemPool "state" statePath)
    (zfsFileSystem systemPool "home/tancredi" "/home/tancredi")
  ];
in
{
  options.local.storage = {
    systemDrives = lib.mkOption {
      type = types.nonEmptyListOf types.path;
      default = [
        /dev/disk/by-id/ata-Lexar_SSD_NS100_512GB_MJ95272016149
        /dev/disk/by-id/ata-Lexar_SSD_NS100_512GB_MJ95272016260
      ];
    };

    systemPool = lib.mkOption {
      type = types.str;
      default = "system";
    };

    ephemeralRoot = lib.mkOption {
      type = types.bool;
      default = true;
    };

    statePath = lib.mkOption {
      type = types.path;
      default = /var/state;
    };

  };

  config = {
    fileSystems = mergeAttrsets [ bootFileSystems systemFileSystems ];

    boot.initrd.postDeviceCommands = mkIf ephemeralRoot (mkAfter ''
      zfs rollback -r ${systemPool}/root@empty
    '');

    boot.tmpOnTmpfs = true;

    services.zfs.autoScrub = {
      enable = true;
      # Run on the first Monday of every month at 02:00.
      interval = "Mon *-*-1..7 02:00:00";
    };

    services.zfs.trim = {
      enable = true;
      # Run on every Friday at 02:00.
      interval = "Fri *-*-* 02:00:00";
    };
  };
}

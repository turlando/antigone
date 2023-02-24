{ config, lib, localLib, ... }:

let
  inherit (builtins) length;
  inherit (lib) mkAfter mkIf range types;
  inherit (localLib.attrsets) mergeAttrsets;
  inherit (localLib.filesystems) bootFileSystem zfsFileSystem zfsFileSystem';

  cfg = config.local.storage;
in {
  options.local.storage = {
    drives = {
      system = lib.mkOption {
        type = types.nonEmptyListOf types.path;
        default = [
          /dev/disk/by-id/ata-Lexar_SSD_NS100_512GB_MJ95272016149
          /dev/disk/by-id/ata-Lexar_SSD_NS100_512GB_MJ95272016260
        ];
      };
    };

    pools = {
      system = lib.mkOption {
        type = types.str;
        default = "system";
      };
      storage = lib.mkOption {
        type = types.str;
        default = "storage";
      };
    };

    datasets = {
      # System datasets
      root = lib.mkOption {
        type = types.str;
        default = "${cfg.pools.system}/root";
      };
      emptyRoot = lib.mkOption {
        type = types.str;
        default = "${cfg.datasets.root}@empty";
      };
      nix = lib.mkOption {
        type = types.str;
        default = "${cfg.pools.system}/nix";
      };
      state = lib.mkOption {
        type = types.str;
        default = "${cfg.pools.system}/state";
      };
      home = lib.mkOption {
        type = types.str;
        default = "${cfg.pools.system}/home";
      };
      services = lib.mkOption {
        type = types.str;
        default = "${cfg.pools.system}/services";
      };

      # Storage datasets
      books = lib.mkOption {
        type = types.str;
        default = "${cfg.pools.storage}/books";
      };
    };

    paths = {
      # System mount points
      state = lib.mkOption {
        type = types.path;
        default = /var/state;
      };
      services = lib.mkOption {
        type = types.path;
        default = /var/services;
      };

      # Storage mount points
      books = lib.mkOption {
        type = types.path;
        default = /mnt/storage/books;
      };
    };

    ephemeralRoot = lib.mkOption {
      type = types.bool;
      default = true;
    };
  };

  config =
    let
      bootFileSystems =
        let
          systemDrives = map toString cfg.drives.system;
          drivesCount = length systemDrives;
          drivesRange = range 1 drivesCount;
        in
          mergeAttrsets (map bootFileSystem drivesRange);

      systemFileSystems =
        let
          statePath = toString cfg.paths.state;
        in
          mergeAttrsets [
            (zfsFileSystem' cfg.datasets.root "/")
            (zfsFileSystem' cfg.datasets.nix "/nix")
            (zfsFileSystem' cfg.datasets.state statePath)
          ];

      storageFileSystems =
        let
          booksPath = toString cfg.paths.books;
        in
          mergeAttrsets [
            (zfsFileSystem' cfg.datasets.books booksPath)
          ];
    in {
      fileSystems = mergeAttrsets [
        bootFileSystems
        systemFileSystems
        storageFileSystems
      ];

      boot.initrd.postDeviceCommands = mkIf cfg.ephemeralRoot (mkAfter ''
        zfs rollback -r ${cfg.datasets.emptyRoot}
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

      users.groups.storage = {
        gid = 5000;
      };
    };
}

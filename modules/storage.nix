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
      backup = lib.mkOption {
        type = types.str;
        default = "backup";
      };
      scratch = lib.mkOption {
        type = types.str;
        default = "scratch";
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
      serviceQuassel = lib.mkOption {
        type = types.str;
        default = "${cfg.datasets.services}/quassel";
      };
      serviceSyncthing = lib.mkOption {
        type = types.str;
        default = "${cfg.datasets.services}/syncting";
      };

      # Storage datasets
      books = lib.mkOption {
        type = types.str;
        default = "${cfg.pools.storage}/books";
      };
      musicElectronic = lib.mkOption {
        type = types.str;
        default = "${cfg.pools.storage}/music/electronic";
      };

      # Scratch datasets
      musicOpusElectronic = lib.mkOption {
        type = types.str;
        default = "${cfg.pools.scratch}/music-opus/electronic";
      };
      musicMp3Electronic = lib.mkOption {
        type = types.str;
        default = "${cfg.pools.scratch}/music-mp3/electronic";
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
      musicElectronic = lib.mkOption {
        type = types.path;
        default = /mnt/storage/music/electronic;
      };

      # Scratch mount points
      musicOpusElectronic = lib.mkOption {
        type = types.path;
        default = /mnt/scratch/music-opus/electronic;
      };
      musicMp3Electronic = lib.mkOption {
        type = types.path;
        default = /mnt/scratch/music-mp3/electronic;
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
          musicElectronicPath = toString cfg.paths.musicElectronic;
          musicOpusElectronicPath = toString cfg.paths.musicOpusElectronic;
          musicMp3ElectronicPath = toString cfg.paths.musicMp3Electronic;
        in
          mergeAttrsets [
            (zfsFileSystem' cfg.datasets.books booksPath)
            (zfsFileSystem' cfg.datasets.musicElectronic musicElectronicPath)
            (zfsFileSystem' cfg.datasets.musicOpusElectronic musicOpusElectronicPath)
            (zfsFileSystem' cfg.datasets.musicMp3Electronic musicMp3ElectronicPath)
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

      services.sanoid = {
        enable = true;
        extraArgs = [ "--verbose" ];
        datasets =
          let
            dailyCfg = {
              yearly = 0;
              monthly = 0;
              daily = 30;
              hourly = 0;
              frequently = 0;
              autosnap = true;
              autoprune = true;
              recursive = false;
            };
            backupCfg = {
              yearly = 0;
              monthly = 12;
              daily = 30;
              hourly = 48;
              autosnap = false;
              autoprune = true;
              recursive = true;
            };
          in {
            # The system state changes so slowly I manually snapshot it.
            # "${cfg.datasets.state}" = dailyCfg;
            "${cfg.datasets.serviceQuassel}" = dailyCfg;
            "${cfg.datasets.books}" = dailyCfg;
            "${cfg.datasets.musicElectronic}" = dailyCfg;
            "${cfg.pools.backup}" = backupCfg;
          };
      };

      services.syncoid = {
        enable = true;
        commands = let
          common = {
            extraArgs = [ "--no-sync-snap" "--no-resume" ];
            sendOptions = "Rw";
            recursive = false;
            localTargetAllow = [
              "change-key" "compression" "create" "mount" "mountpoint"
              "receive" "rollback" "acltype"
            ];
          };

          # type: str -> str -> str
          # Example:
          #  addPrefix "system/services/quassel"
          #  => "backup/system/services/quassel"
          addBackupPrefix = dataset: cfg.pools.backup + "/" + dataset;
        in {
          "${cfg.datasets.state}" =
            { target = addBackupPrefix cfg.datasets.state; } // common;
          "${cfg.datasets.serviceQuassel}" =
            { target = addBackupPrefix cfg.datasets.serviceQuassel; } // common;
          "${cfg.datasets.books}" =
            { target = addBackupPrefix cfg.datasets.books; } // common;
          "${cfg.datasets.musicElectronic}" =
            { target = addBackupPrefix cfg.datasets.musicElectronic; } // common;
        };
      };

      users.groups.storage = {
        gid = 5000;
      };
    };
}

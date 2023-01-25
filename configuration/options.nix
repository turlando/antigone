{ lib, ... }:

{
  options = {
    system.systemDrives = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.path;
    };

    system.statePath = lib.mkOption {
      type = lib.types.path;
    };
  };
}

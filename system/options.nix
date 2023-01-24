{ lib, ... }:

{
  options = {
    system.systemDrives = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.string;
    };
  };
}

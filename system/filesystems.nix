{ ... }:

{
  fileSystems."/" =
    { device = "system/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "system/nix";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/255c1607-4694-46fa-84f3-4c9ec5948018";
      fsType = "ext4";
    };

  fileSystems."/home/tancredi" =
    { device = "fast-storage/home/tancredi";
      fsType = "zfs";
    };
}

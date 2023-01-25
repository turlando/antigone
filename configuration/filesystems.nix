{ ... }:

{
  fileSystems."/boot/1" =
    { device = "/dev/disk/by-uuid/f64ccec2-63ff-4d7b-bf47-64fa04550b14";
      fsType = "ext4";
    };

  fileSystems."/boot/2" =
    { device = "/dev/disk/by-uuid/a0a5d348-5e89-4022-a835-403547a4b36d";
      fsType = "ext4";
    };

  fileSystems."/" =
    { device = "system/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "system/nix";
      fsType = "zfs";
    };

  fileSystems."/state" =
    { device = "system/state";
      fsType = "zfs";
    };

  fileSystems."/home/tancredi" =
    { device = "system/home/tancredi";
      fsType = "zfs";
    };
}

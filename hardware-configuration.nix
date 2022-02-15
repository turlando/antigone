# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "ohci_pci" "ehci_pci" "pata_jmicron" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

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

  fileSystems."/mnt/music/edm" =
    { device = "large-storage/music/edm";
      fsType = "zfs";
    };

  swapDevices = [ ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

{ utils, ... }:

{
  boot.loader.grub = {
    enable = true;
    version = 2;
    devices = [
      "/dev/disk/by-path/pci-0000:03:00.0-usb-0:1:1.0-scsi-0:0:0:0"
      "/dev/disk/by-path/pci-0000:03:00.0-usb-0:2:1.0-scsi-0:0:0:0"
    ];
  };

  # From hardware-configuration.nix
  boot.kernelModules = [ "kvm-amd" ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.tmpOnTmpfs = true;

  boot.initrd = {
    # From hardware-configuration.nix
    availableKernelModules = [
      "ahci"
      "ohci_pci"
      "ehci_pci"
      "pata_jmicron"
      "xhci_pci"
      "usb_storage"
      "sd_mod"
    ];

    kernelModules = [ "r8169" ];

    network = {
      enable = true;

      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [
          "/etc/secrets/initrd_ssh_host_rsa_key"
          "/etc/secrets/initrd_ssh_host_ed25519_key"
        ];
        authorizedKeys = [ (utils.readSshKey "boot") ];
      };
    };
  };

  hardware.cpu.amd.updateMicrocode = true;
}

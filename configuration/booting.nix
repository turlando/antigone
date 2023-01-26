{ config, lib, util, ... }:

let

  grubMirroredBoots =
    lib.lists.imap1
      (index: drive: {
        devices = [ (toString drive) ];
        path    = "/boot/${toString index}";
      })
      config.system.systemDrives;

  sshHostKeys =
    map
      toString
      [
        (config.system.statePath + "/etc/ssh-initrd/ssh_host_rsa_key")
        (config.system.statePath + "/etc/ssh-initrd/ssh_host_ed25519_key")
      ];

in

{
  boot.loader.grub = {
    enable = true;
    version = 2;
    mirroredBoots = grubMirroredBoots;
  };

  boot.initrd.kernelModules = [ "r8169" ];
  boot.supportedFilesystems = [ "zfs" ];

  boot.initrd.network = {
    enable = true;

    ssh = {
      enable = true;
      port = 2222;
      hostKeys = sshHostKeys;
      authorizedKeys = [ (util.readSshKey "boot") ];
    };
  };

  boot.tmpOnTmpfs = true;

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r system/root@empty
  '';
}

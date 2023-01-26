{ config, lib, localLib, ... }:

let
  inherit (lib.lists) imap1;
  inherit (localLib.files) readSshKey;

  statePath = toString config.system.statePath;

  grubMirroredBoots =
    imap1
      (index: drive: {
        devices = [ (toString drive) ];
        path    = "/boot/${toString index}";
      })
      config.system.systemDrives;

  sshHostKeys = [
    (statePath + "/etc/ssh-initrd/ssh_host_rsa_key")
    (statePath + "/etc/ssh-initrd/ssh_host_ed25519_key")
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
      authorizedKeys = [ (readSshKey "boot") ];
    };
  };

  boot.tmpOnTmpfs = true;

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r system/root@empty
  '';
}

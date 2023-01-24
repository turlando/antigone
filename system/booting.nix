{ config, lib, util, ... }:

let

  grubMirroredBoots =
    map ({fst, snd}:
      let
        drive = snd;
        i     = toString (fst + 1);
      in
        {
          devices = [ drive ];
          path    = "/boot/${i}";
        })
      (util.enumerate config.system.systemDrives);

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
      hostKeys = [
        "/etc/secrets/initrd_ssh_host_rsa_key"
        "/etc/secrets/initrd_ssh_host_ed25519_key"
      ];
      authorizedKeys = [ (util.readSshKey "boot") ];
    };
  };

  boot.tmpOnTmpfs = true;

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@empty
  '';
}

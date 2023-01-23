{ lib, util, ... }:

{
  boot.loader.grub = {
    enable = true;
    version = 2;
    mirroredBoots = [
      {
        devices = [ "/dev/disk/by-id/ata-Lexar_SSD_NS100_512GB_MJ95272016149" ];
        path    = "/boot/1";
      }
      {
        devices = [ "/dev/disk/by-id/ata-Lexar_SSD_NS100_512GB_MJ95272016260" ];
        path    = "/boot/2";
      }
    ];
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

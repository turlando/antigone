{ ... }:

{
  fileSystems."/var/services/quassel" = {
    device = "system/services/quassel";
    fsType = "zfs";
  };

  containers.quassel = {
    ephemeral = true;
    autoStart = true;
    bindMounts = {
      "/etc/resolv.conf" = {
        hostPath = "/etc/resolv.conf";
        isReadOnly = true;
      };
      "/data" = {
        hostPath = "/var/services/quassel";
        isReadOnly = false;
      };
    };

    config =
      { config, pkgs, ... }:
      {
        system.stateVersion = "22.11";

        environment.systemPackages = [
          ## So that I can run:
          # nixos-container root-login quassel
          # sudo -u quassel openssl req -x509 -nodes -days 365 \
          #   -newkey rsa:4096 -keyout /data/quasselCert.pem   \
          #   -out /data/quasselCert.pem
          pkgs.openssl

          ## So that I can run:
          # nixos-container root-login quassel
          # sudo -u quassel quasselcore --configdir=/data --add-user
          pkgs.quasselDaemon
        ];
        services.quassel = {
          enable = true;
          dataDir = "/data";
        };
      };
  };
}
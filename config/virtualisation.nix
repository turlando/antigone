{ config, pkgs, ... }:

let
  storageCfg = config.local.storage;
in
{
  virtualisation = {
    podman = {
      enable = true;
      extraPackages = [ pkgs.zfs ];
    };
    
    containers.storage.settings.storage = {
      driver = "zfs";
      graphroot = "/var/lib/containers/storage";
      runroot = "/run/containers/storage";

      options.zfs = {
        fsname = storageCfg.datasets.podman;
      };
    };
  };
}

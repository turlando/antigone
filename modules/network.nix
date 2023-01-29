{ config, lib, ... }:

let
  inherit (lib) mkOption types;
  inherit (lib.attrsets) mapAttrs' nameValuePair;

  cfg = config.local.network;
in
{
  options.local.network.interfaces = mkOption {
    type = types.attrsOf (types.submodule (
      { config, options, name, ... }:
      {
        options = {
          mac = mkOption {
            type = types.str;
          };
          useDHCP = mkOption {
            type = types.bool;
          };
        };
      }
    ));
    default = {
      "eth0" = {
        mac = "f4:6d:04:7b:d3:0e";
        useDHCP = true;
      };
    };
  };

  config = {
    systemd.network.links = mapAttrs'
      (name: config: nameValuePair
        "10-${name}"
        {
          matchConfig.PermanentMACAddress = config.mac;
          linkConfig.Name = name;
        }
      )
      cfg.interfaces;

    networking = {
      hostName = "antigone";
      hostId = "4d86c32a"; # Required by ZFS

      interfaces = mapAttrs'
        (name: config: nameValuePair name { useDHCP = config.useDHCP; })
        cfg.interfaces;
    };
  };
}

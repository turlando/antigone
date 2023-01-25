{ ... }:

let
  hostname = "antigone";
  hostId = "4d86c32a"; # Required by ZFS

  # type: iface
  eth0 =
    { name = "eth0";
      mac  = "f4:6d:04:7b:d3:0e";
    };
in
{
  systemd.network.links."10-${eth0.name}" = {
    matchConfig.PermanentMACAddress = eth0.mac;
    linkConfig.Name = eth0.name;
  };

  networking = {
    hostName = hostname;
    useDHCP = false;
    interfaces.${eth0.name}.useDHCP = true;
    hostId = hostId;
  };
}

{ ... }:

let
  hostname = "antigone";
  hostId = "4d86c32a"; # Required by ZFS

  # type: iface
  eth0 =
    { name = "eth0";
      mac  = "f4:6d:04:7b:d3:0e";
    };

  # type: iface -> str
  udevRule = { name, mac }:
    ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${mac}", NAME="${name}"
    '';
in
{
  # This also applies to initrd.
  services.udev.extraRules = udevRule eth0;

  networking = {
    hostName = hostname;
    useDHCP = false;
    interfaces.${eth0.name}.useDHCP = true;
    hostId = hostId;
  };
}

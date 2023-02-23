{ ... }@args:

let
  localFilesystems = import ./filesystems.nix args;
  inherit (localFilesystems) servicePath;

  # type: path
  dataPath = /data;
in {
  dataPath = dataPath;

  # type: AttrSet
  resolvBindMount = {
    "/etc/resolv.conf" = {
      hostPath = "/etc/resolv.conf";
      isReadOnly = true;
    };
  };

  # type: str
  dataBindMount = serviceName: {
    "${toString dataPath}" = {
      hostPath = toString (servicePath serviceName);
      isReadOnly = false;
    };
  };

  # type: path -> AttrSet
  hostBindMount = hostPath: {
    "${toString hostPath}" = {
      hostPath = toString hostPath;
      isReadOnly = false;
    };
  };
}

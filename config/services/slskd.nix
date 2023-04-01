{ config, localLib, localPkgs, ... }:

let
  inherit (localLib.attrsets) mergeAttrsets;
  inherit (localLib.filesystems) serviceFileSystem servicePath;
  inherit (localLib.services) dataPath resolvBindMount dataBindMount;

  name = "slskd";

  localModules = dirOf <nixos-config> + /modules;
in
{
  containers."${name}" = {
    ephemeral = true;
    autoStart = true;

    bindMounts = mergeAttrsets [
      resolvBindMount
    ];

    config =
      { ... }:
      {
        imports = [ localModules ];

        config = {
          system.stateVersion = "22.11";

          services.slskd = {
            enable = true;
            package = localPkgs.slskd;
          };
        };
      };
  };
}

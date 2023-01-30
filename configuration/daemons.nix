{ config, lib, options, ... }:

let
  statePath = toString config.local.storage.paths.state;

  sshHostKeys =
    map
      (attr:
        lib.updateManyAttrsByPath
          [ {
              path = [ "path" ];
              update = p: "${statePath}/${p}";
          } ]
          attr)
      options.services.openssh.hostKeys.default;
in
{
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "prohibit-password";
    hostKeys = sshHostKeys;
  };
}

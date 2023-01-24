{ config, lib, options, ... }:

let

  sshHostKeys =
    map
      (attr:
        lib.updateManyAttrsByPath
          [ {
              path = [ "path" ];
              update = p: toString (config.system.statePath + p);
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

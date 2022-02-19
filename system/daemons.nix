{ ... }:

{
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "prohibit-password";
    forwardX11 = true;
  };

  services.apcupsd = {
    enable = true;
  };
}

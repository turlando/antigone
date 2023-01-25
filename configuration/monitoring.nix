{ localPkgs, config, ... }:

let
  notifyCmd = "${localPkgs.telegram-send}/bin/telegram-send";
  notifyConf = toString (config.system.statePath + /etc/telegram-send.ini);
in

{
  services.zfs.zed.settings = {
    ZED_EMAIL_ADDR = [ "root" ];
    ZED_EMAIL_PROG = notifyCmd;
    ZED_EMAIL_OPTS = "-c ${notifyConf} -r ZFS -s '@SUBJECT@'";
    ZED_NOTIFY_VERBOSE = true;
  };
}

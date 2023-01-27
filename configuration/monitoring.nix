{ pkgs, localPkgs, config, ... }:

let
  statePath = toString config.local.storage.statePath;
  notifyCmd = "${localPkgs.telegram-send}/bin/telegram-send";
  notifyConf = "${statePath}/etc/telegram-send.ini";

  notify = from: subject: message:
    pkgs.writeShellScript "notify.sh" ''
      set -e
      echo "${message}" | ${notifyCmd} -c ${notifyConf} -r "${from}" -s "${subject}"
    '';

  smartdNotify = notify
    "SMART"
    "SMART error ($SMARTD_FAILTYPE) detected"
    ''
      The following warning/error was logged by the smartd daemon:
      $SMARTD_MESSAGE

      Device info:
      $SMARTD_DEVICEINFO
    '';

  upsOnBatteryNotify = notify
    "UPS"
    "Detected power interruption"
    "A power interruption has been detected. Running on batteries.";

  upsOffBatteryNotify = notify
    "UPS"
    "Power restored"
    "The power interruption is over. Running on mains.";

in

{
  services.zfs.zed.settings = {
    ZED_EMAIL_ADDR = [ "root" ];
    ZED_EMAIL_PROG = notifyCmd;
    ZED_EMAIL_OPTS = "-c ${notifyConf} -r ZFS -s '@SUBJECT@'";
    ZED_NOTIFY_VERBOSE = true;
  };

  services.smartd = {
    enable = true;
    extraOptions = [ "-w ${smartdNotify.outPath}" ];
  };

  services.apcupsd = {
    enable = true;
    hooks = {
      onbattery = upsOnBatteryNotify.outPath;
      offbattery = upsOffBatteryNotify.outPath;
    };
  };
}

{ pkgs, localPkgs, config, ... }:

let
  notifyCmd = "${localPkgs.telegram-send}/bin/telegram-send";
  notifyConf = toString (config.system.statePath + /etc/telegram-send.ini);

  smartdNotify = pkgs.writeShellScript "smartd-notify.sh" ''
    set -e
    HOSTNAME=${config.networking.hostName}
    FROM="SMART"
    SUBJECT="SMART error ($SMARTD_FAILTYPE) detected on $HOSTNAME"
    MESSAGE=$(
      echo "The following warning/error was logged by the smartd daemon:"
      echo "$SMARTD_MESSAGE"
      echo
      echo "Device info:"
      echo "$SMARTD_DEVICEINFO"
    )
    echo $MESSAGE | ${notifyCmd} -c ${notifyConf} -r "$FROM" -s "$SUBJECT"
  '';

  upsOnBattery = pkgs.writeShellScript "ups-onbattery.sh" ''
    set -e
    HOSTNAME=${config.networking.hostName}
    FROM="UPS"
    SUBJECT="Power interruption at $HOSTNAME"
    MESSAGE="A power interruption has been detected. Running on batteries."
    echo $MESSAGE | ${notifyCmd} -c ${notifyConf} -r "$FROM" -s "$SUBJECT"
  '';

  upsOffBattery = pkgs.writeShellScript "ups-offbattery.sh" ''
    set -e
    HOSTNAME=${config.networking.hostName}
    FROM="UPS"
    SUBJECT="Power restored at $HOSTNAME"
    MESSAGE="The power interruption is over. Running on mains."
    echo $MESSAGE | ${notifyCmd} -c ${notifyConf} -r "$FROM" -s "$SUBJECT"
  '';
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
      onbattery = upsOnBattery.outPath;
      offbattery = upsOffBattery.outPath;
    };
  };
}

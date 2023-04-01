{ config, lib, localPkgs, ... }:

let
  cfg = config.services.slskd;
  slskd = cfg.package;
  user = if cfg.user != null then cfg.user else "slskd";
in {
  options = {
    services.slskd = {
      enable = lib.mkEnableOption (lib.mkDoc "slskd daemon");

      package = lib.mkOption {
        type = lib.types.package;
        default = localPkgs.slskd;
        description = lib.mkDoc "The slskd package.";
      };

      user = lib.mkOption {
        default = null;
        type = lib.types.nullOr lib.types.str;
        description = lib.mdDoc ''
          The existing user the slskd daemon should run as.
          If left empty, a default "slskd" user will be created.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    ids.uids.slskd = 327;
    ids.gids.slskd = 327;

    users.users = lib.optionalAttrs (cfg.user == null) {
      slskd = {
        name = "slskd";
        description = "slskd daemon";
        group = "slskd";
        uid = config.ids.uids.slskd;
      };
    };

    users.groups = lib.optionalAttrs (cfg.user == null) {
      slskd = {
        name = "slskd";
        gid = config.ids.gids.slskd;
      };
    };

    systemd.services.slskd = {
      description = "slskd daemon";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${slskd}/bin/slskd";
        User = user;
      };
    };
  };
}

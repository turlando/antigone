{ pkgs, config, localLib, ... }:

let
  inherit (localLib.attrsets) mergeAttrsets;
  inherit (localLib.filesystems) serviceFileSystem servicePath;

  storageCfg = config.local.storage;
  storageGroup = config.users.groups.storage;

  name = "slskd";
  version = "0.17.5";

  httpPort = 5030;
  soulseekNetPort = 23530;

  uid = 327;
  gid = 327;

  dataPath = "/app";

  baseImage = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/slskd/slskd";
    imageDigest = "sha256:a547ebd75bc7e10d8bdbee4108bb544bce99cb03647ab071175a5919aa363dd2";
    sha256 = "1cv0kqsqcjaacfny3qcqjp4nlhnpf6ry34k7c10lbgf8bk5940a3";
    finalImageName = "ghcr.io/slskd/slskd";
    finalImageTag = "0.17.5";
  };

  image = pkgs.dockerTools.buildImage {
    name = name;
    tag = version;
    fromImage = baseImage;
    runAsRoot = ''
      #!${pkgs.runtimeShell}
      ${pkgs.dockerTools.shadowSetup}
      groupadd -r -g ${toString gid} ${name}
      useradd -r -u ${toString uid} -g ${toString gid} ${name}
    '';
    config = {
      WorkingDir = "/slskd";
      Entrypoint = [ "/usr/bin/tini" "--" "./slskd" ];
    };
  };
in
{
  ids.uids."${name}" = uid;
  ids.gids."${name}" = gid;

  users.users."${name}" = {
    name = name;
    description = "slskd daemon";
    group = name;
    uid = config.ids.uids."${name}";
    isSystemUser = true;
    extraGroups = [ storageGroup.name ];
  };

  users.groups."${name}" = {
    name = name;
    gid = config.ids.gids."${name}";
  };

  fileSystems = mergeAttrsets [
    (serviceFileSystem name)
  ];

  virtualisation.oci-containers.containers."${name}" = {
    imageFile = image;
    image = "${name}:${version}";
    user = "${name}:${name}";
    volumes =
      let
        volumeBind = path: "${toString path}:${toString path}";
        volumeBindRo = path: "${toString path}:${toString path}:ro";
      in [
        "${toString (servicePath name)}:${toString dataPath}"
        (volumeBind storageCfg.paths.downloadsSlskd)
        (volumeBindRo storageCfg.paths.musicElectronic)
      ];
    ports = [
      "${toString httpPort}:${toString httpPort}"
      "${toString soulseekNetPort}:${toString soulseekNetPort}"
    ];
    autoStart = true;
  };

  networking.firewall.interfaces."eth0".allowedTCPPorts = [ soulseekNetPort ];
}

{ config, pkgs, ... }:

{
  system.stateVersion = "20.03";

  imports = [ ./hardware-configuration.nix
              ./storage.nix
              ./services/quassel.nix
              ./services/syncthing.nix
            ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      devices = [ "/dev/disk/by-path/pci-0000:03:00.0-usb-0:1:1.0-scsi-0:0:0:0"
                  "/dev/disk/by-path/pci-0000:03:00.0-usb-0:2:1.0-scsi-0:0:0:0" ];
    };

    initrd = {
      kernelModules = [ "r8169" ];
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          hostKeys = [ "/etc/secrets/initrd_ssh_host_rsa_key"
                       "/etc/secrets/initrd_ssh_host_ed25519_key" ];
          authorizedKeys = [ (builtins.readFile ./ssh-keys/boot.pub) ];
        };
      };
    };

    supportedFilesystems = [ "zfs" ];
    tmpOnTmpfs = true;
  };

  networking = {
    hostName = "antigone";
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
    hostId = "4d86c32a";
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  time.timeZone = "UTC";

  security.sudo.enable = true;

  services.udev.extraRules =
    ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="f4:6d:04:7b:d3:0e", NAME="eth0"
    '';

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "prohibit-password";
    forwardX11 = true;
  };

  services.apcupsd = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    lm_sensors hddtemp
    cryptsetup
    zsh grml-zsh-config
    tmux
    gnumake
    git
    (emacs.override { withGTK2 = false; withGTK3 = false; })
  ];

  fonts.fonts = with pkgs; [
    source-code-pro
  ];

  programs = {
    zsh = {
      enable = true;
      promptInit = ""; # unset to use grml prompt
      interactiveShellInit = ''
        source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
      '';
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
    };
  };

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;

    users.root = {
      hashedPassword = "$6$FSwdvci6$jhZ2Ge5tbaYquhuo9.0S1jGwVyIttqXvmlCXRVoZ4BlC.tsTyOcRjJ.iiyREF57zOk/GG/wClazVwVL3NqlQ/0";
      openssh.authorizedKeys.keyFiles = [ ./ssh-keys/tancredi.pub ];
    };

    users.tancredi = {
      isNormalUser = true;
      extraGroups = [ "wheel"
                      config.users.groups.storage-books.name
                    ];
      hashedPassword = "$6$FSwdvci6$jhZ2Ge5tbaYquhuo9.0S1jGwVyIttqXvmlCXRVoZ4BlC.tsTyOcRjJ.iiyREF57zOk/GG/wClazVwVL3NqlQ/0";
      openssh.authorizedKeys.keyFiles = [ ./ssh-keys/tancredi.pub ];
    };
  };
}

{ config, pkgs, ... }:

{
  system.stateVersion = "20.03";

  imports = [ ./hardware-configuration.nix ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      devices = [ "/dev/disk/by-path/pci-0000:02:00.0-usb-0:1:1.0-scsi-0:0:0:0"
                  "/dev/disk/by-path/pci-0000:02:00.0-usb-0:2:1.0-scsi-0:0:0:0" ];
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
    interfaces.enp3s0.useDHCP = true;
    hostId = "4d86c32a";
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  time.timeZone = "UTC";

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "prohibit-password";
  };

  environment.systemPackages = with pkgs; [
    lm_sensors hddtemp
    gnumake
    zsh grml-zsh-config
    tmux
  ];

  programs = {
    zsh = {
      enable = true;
      promptInit = ""; # unset to use grml prompt
      interactiveShellInit = ''
        source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
      '';
    };
  };

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;

    users.root = {
      openssh.authorizedKeys.keyFiles = [ ./ssh-keys/tancredi.pub ];
    };

    users.tancredi = {
      isNormalUser = true;
      openssh.authorizedKeys.keyFiles = [ ./ssh-keys/tancredi.pub ];
    };
  };
}

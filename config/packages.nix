{ pkgs, localPkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pciutils
    usbutils

    smartmontools
    lm_sensors
    hddtemp

    zsh
    grml-zsh-config

    tmux
    gnumake
    git

    localPkgs.telegram-send
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
}

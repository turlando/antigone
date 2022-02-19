{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cryptsetup

    lm_sensors
    hddtemp

    zsh
    grml-zsh-config

    tmux
    gnumake
    git

    (emacs.override { withGTK2 = false; withGTK3 = false; })
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

  fonts.fonts = with pkgs; [
    source-code-pro
  ];
}

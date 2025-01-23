{ pkgs, ... }: {
  # Let home-manager install and manage itself.
  programs.home-manager.enable = true;

  home =
    {
      # this is internal compatibility configuration 
      # for home-manager, don't change this!
      stateVersion = "23.05";
      username = "hassibz";
      homeDirectory = "/Users/hassibz";
      packages = with pkgs; [
        pkgs.git
      ];
      sessionVariables = {
        EDITOR = "vim";
      };
      file = {
        ".vimrc".source = ./vim_config;
        ".config/git/config".source = ./git_config;
        ".config/git/ignore".source = ./git_ignore;
      };
    };


  programs = {
    zsh = {
      enable = true;
      shellAliases = {
        switch = "darwin-rebuild switch --flake ~/.config/nix";
      };
    };

    vscode = {
      enable = true;

      userSettings = builtins.fromJSON (builtins.readFile ./vscode_settings.json);
      keybindings = builtins.fromJSON (builtins.readFile ./vscode_keybindings.json);

      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        dracula-theme.theme-dracula
        vscodevim.vim
        bradlc.vscode-tailwindcss
        astro-build.astro-vscode
        github.copilot-chat
      ];
    };
  };
}

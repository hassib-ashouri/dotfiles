{ pkgs, ... }:
{
  # Let home-manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
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
      ".cursor/User/settings.json".source = ./vscode_settings.json;
      ".cursor/User/keybindings.json".source = ./vscode_keybindings.json;
    };
  };

  programs = {
    zsh = {
      enable = true;
      shellAliases = {
        switch = "darwin-rebuild switch --flake ~/.config/nix";
        # since cursor is not installed via home manager, we have to manually copy the settings files and pull the extensions from vscode
        c = "cursor ";
      };
    };

    vscode = {
      enable = false;
      # disable to get extensions to work across vscode and cursor
      mutableExtensionsDir = false;
      profiles.default = {
        userSettings = builtins.fromJSON (builtins.readFile ./vscode_settings.json);
        keybindings = builtins.fromJSON (builtins.readFile ./vscode_keybindings.json);
        extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        dracula-theme.theme-dracula
        vscodevim.vim
        bradlc.vscode-tailwindcss
        astro-build.astro-vscode
        github.copilot-chat
        hashicorp.terraform
      ];
      };
    };
  };
}

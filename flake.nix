{
  description = "My system configuration";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      nix-vscode-extensions,
      determinate,
    }:
    let
      input_user = "hassibz";
      input_hostname = "Soummiehs-MacBook-Air";
      input_homeDirectory = "/Users/${input_user}";
      configuration =
        { pkgs, ... }:
        {

          nix.enable = false;

          # The platform the configuration will be used on.
          # If you're on an Intel system, replace with "x86_64-darwin"
          nixpkgs.hostPlatform = "aarch64-darwin";

          system.stateVersion = 6;

          # Declare the user that will be running `nix-darwin`.
          users.users."${input_user}" = {
            name = input_user;
            home = "/Users/${input_user}";
          };

          # Create /etc/zshrc that loads the nix-darwin environment.
          programs.zsh.enable = true;

          environment.systemPackages = with pkgs; [
            neofetch
            vim
            neovim
            nixfmt-rfc-style
            discord
            spotify
            zoom-us
            postman
            docker
            docker-compose
            google-chrome
            nodejs_22
            arc-browser
            inkscape
            raycast
          ];
          homebrew = {
            enable = true;
            onActivation = {
              # autoupdate homebrew on switch
              autoUpdate = true;
              cleanup = "uninstall";
              upgrade = true;
            };

            taps = [ ];
            brews = [ "cowsay" ];
            casks = [
              "copilot"
              "notion"
              "chatgpt"
              "logi-options+"
              "tradingview"
              "tailscale"
              "windows-app"
            ];
            masApps = {
              "PixelMator" = 1289583905;
            };
          };

          nixpkgs = {
            config.allowUnfree = true;
            overlays = [
              nix-vscode-extensions.overlays.default
            ];
          };

          # key remaping
          system = {
            defaults = {
              dock.autohide = true;
            };
            keyboard = {
              enableKeyMapping = true;
              remapCapsLockToControl = true;
            };
          };
        };
    in
    {
      # darwinConfigurations."HOST NAME" = nix-darwin.lib.darwinSystem {
      darwinConfigurations."${input_hostname}" = nix-darwin.lib.darwinSystem {
        system = "pinkair";
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users."${input_user}" = import ./home.nix;
          }
        ];
      };
    };
}

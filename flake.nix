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
      input_user = "hassiba";
      input_hostname = "bluefish";
      input_homeDirectory = "/Users/${input_user}";
      configuration =
        { pkgs, ... }:
        {

          # leave nix disabled because it is managed by determinate
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
            postman
            docker
            docker-compose
            google-chrome
            nodejs_22
            arc-browser
            inkscape
            raycast
            pnpm_10
            awscli2
            opentofu
            slack
            nil
            # for python
            # python312Full
            # python312Packages.pip
            # python312Packages.setuptools
            # uv
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
              "teamviewer"
              "1password"
              "spotify"
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
            primaryUser = input_user;

            defaults = {
              dock = {
                autohide = true;
                orientation = "right";
                persistent-apps = [
                  "/System/Applications/Mail.app"
                  "/System/Applications/Calendar.app"
                  "/System/Applications/Notion.app"
                ];
              };
              NSGlobalDomain = {
                InitialKeyRepeat = 15; # Normal minimum is 15 (225ms)
                KeyRepeat = 2; # Normal minimum is 2 (30ms)
                ApplePressAndHoldEnabled = false; # This disables the character picker and enables key repeat
                NSAutomaticSpellingCorrectionEnabled = false; # Disables auto-correction
              };
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

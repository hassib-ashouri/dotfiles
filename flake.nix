{
  description = "My system configuration";

  inputs = {
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

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-vscode-extensions }:
    let
      configuration = { pkgs, ... }: {

        services.nix-daemon.enable = true;
        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility. please read the changelog
        # before changing: `darwin-rebuild changelog`.
        system.stateVersion = 4;

        # The platform the configuration will be used on.
        # If you're on an Intel system, replace with "x86_64-darwin"
        nixpkgs.hostPlatform = "aarch64-darwin";

        # Declare the user that will be running `nix-darwin`.
        users.users.hassiba = {
          name = "hassiba";
          home = "/Users/hassiba";
        };

        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh.enable = true;

        environment.systemPackages = with pkgs; [
          neofetch
          vim
          nixpkgs-fmt
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
        ];
        homebrew = {
          enable = true;
          onActivation.cleanup = "uninstall";
          onActivation.upgrade = true;

          taps = [ ];
          brews = [ "cowsay" ];
          casks = [ "copilot" "notion" "chatgpt" "logi-options+" "tradingview" ];
          masApps = { };
        };

        nixpkgs = {
          config.allowUnfree = true;
          overlays = [
            nix-vscode-extensions.overlays.default
          ];
        };

      };
    in
    {
      darwinConfigurations."expensive" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users.hassiba = import ./home.nix;
          }
        ];
      };
    };
}


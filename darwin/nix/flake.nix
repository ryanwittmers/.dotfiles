{
  description = "Zenful Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, ... }:
  let
    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = [
        pkgs.neovim
        pkgs.mkalias
        pkgs.micro
        pkgs.vscode
        pkgs.docker
        pkgs.raycast
      ];

      homebrew = {
        enable = true;
        brews = [
          "oh-my-posh"
	  	  "gh"
	  	  "java"
        ];
        casks = [
          "raycast"
          "warp"
          "firefox"
          "arc"
          "notion"
          "notion-calendar"
          "superhuman"
          "spotify"
          "slack"
	  	  "1password"
          "orbstack"
          "shottr"
          "maccy"
          "zoom" 
        ];

        masApps = {
          "Windows App" = 1295203466;
          "Xcode" = 497799835;
        };

        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
      };



      services.nix-daemon.enable = true;

      nix.settings.experimental-features = "nix-command flakes";

      programs.zsh.enable = true;

      system.configurationRevision = self.rev or self.dirtyRev or null;

      system.stateVersion = 5;

      nixpkgs.hostPlatform = "aarch64-darwin";

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
        '';

        # Default macOS Settings
        system.defaults = {
            dock.autohide = true;
            dock.persistent-apps = [
                "/System/Applications/Messages.app"
                "/Applications/Arc.app"
                "/Applications/Notion.app"
                "/Applications/Notion Calendar.app"
                "/Applications/Superhuman.app"
                "/Applications/Spotify.app"
                "${pkgs.vscode}/Applications/Visual Studio Code.app"
                "/Applications/Warp.app"
                "/Applications/Slack.app"

            ];

            finder.FXPreferredViewStyle = "clmv";
            loginwindow.GuestEnabled = false;
            NSGlobalDomain.AppleInterfaceStyle = "Dark";
            NSGlobalDomain.KeyRepeat = 2;
        };
    };
  in
  {
    darwinConfigurations."workMac" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Enable Homebrew via Nix
            enable = true;

            # Enables Rosetta
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "ryan.wittmers";

            # Automigrate Homebrew packages to Nix. Now that homebrew is migrated successfully, this option doesn't need to be in there.
            # autoMigrate = true;
          };
        }
      ];
    };
  };
}

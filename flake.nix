{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, mac-app-util, nix-homebrew, nixpkgs }:
  let
    configuration = { pkgs, config, ... }: {
      
      # Pedantic OSS purist stuff
      nixpkgs.config.allowUnfree = true;

      # Nix packages
      environment.systemPackages =
        [ pkgs.vscodium
          pkgs.iterm2
          pkgs.firefox
          pkgs.thunderbird
          pkgs.reaper
          pkgs.ffmpeg
          pkgs.transmission_4
          pkgs.prismlauncher
        ];

      # Homebrew packages
      homebrew = {
        enable = true;
        # Regular homebrew cli tools
        brews = [
          "mas" # Utility for getting mac app store IDs
          "cloudflared"
          "node"
          "pnpm"
          "python"
        ];
        # Regular casks
        casks = [
          "github" # Github Desktop
          "signal"
          # "ente-auth"
          "vlc"
          "docker"
        ];
        # Mac app store apps
        masApps = {
          "R101" = 1519963914;
        };
        onActivation.cleanup = "zap"; # on install, delete everything that wasn't listed above
        # Autoupdate
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # MacOS settings
      system.defaults = {
        dock = {
          autohide = true;
          persistent-apps = [
            "${pkgs.firefox}/Applications/Firefox.app"
            "${pkgs.thunderbird}/Applications/Thunderbird.app"
            "/Applications/Signal.app"
            "/Applications/Ente Auth.app"
            "${pkgs.iterm2}/Applications/iTerm.app"
            "/System/Applications/Activity Monitor.app"
            "/Applications/GitHub Desktop.app"
            "${pkgs.vscodium}/Applications/VSCodium.app"
            "${pkgs.reaper}/Applications/REAPER.app"
            "/System/Applications/System Settings.app"
          ];
          # Hot corners
          wvous-bl-corner = 13; # Bottom left - lock screen
        };
        finder.FXPreferredViewStyle = "clmv"; # Column layout

        NSGlobalDomain = {
          # AppleLocale = "en_NZ";
          # AppleLanguages = ["en-NZ" "mi-NZ"];
          AppleShowScrollBars = "Always";
          AppleScrollerPagingBehavior = true;
          AppleInterfaceStyleSwitchesAutomatically = true;
          # AppleAccentColor = 1;
          # AppleHighlightColor = "1.000000 0.874510 0.701961 Orange";
          AppleShowAllExtensions = true;
        };
      };
      system.activationScripts.postActivation.text = ''
        # Trackpad
        defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
        defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true # tap-to-click
        defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 1 # hardness
        defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 2 # quick look
        defaults write com.apple.trackpad.forceClick -bool false

        # Menu bar
        defaults write com.apple.menuextra.clock ShowSeconds -bool true
        defaults write com.apple.controlcenter BatteryShowPercentage -bool true

        # Disable gatekeeper
        spctl --master-disable

        # Restart stuff
        killall ControlCenter || true
        killall SystemUIServer || true

        # Apply all settings
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';

      # Touch ID for sudo
      security.pam.services.sudo_local.touchIdAuth = true;


      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Makes homebrew work
      system.primaryUser = "zade";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#cooked
    darwinConfigurations."cooked" = nix-darwin.lib.darwinSystem {
      modules =
        [ mac-app-util.darwinModules.default # So stuff gets indexed in spotlight
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "zade";
              autoMigrate = true;
            };
          }
        ];
    };
  };
}

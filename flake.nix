{
  description = "Cooked nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
  };

  outputs = inputs@{ self, nix-darwin, mac-app-util, nix-homebrew, nixpkgs, nix-vscode-extensions, ... }:
  let
    configuration = { pkgs, config, ... }: {

      # Inject vscode extensions into pkgs
      nixpkgs.overlays = [
        nix-vscode-extensions.overlays.default
        # nixpkgs doesn't have Mozilla's Firefox builds,
        # which have macos passkey support, so need this overlay
        inputs.nixpkgs-firefox-darwin.overlay
      ];
      
      # Pedantic OSS purist stuff
      nixpkgs.config.allowUnfree = true;

      # Nix packages
      environment.systemPackages =
        [
          (pkgs.vscode-with-extensions.override {
            vscode = pkgs.vscodium;
            vscodeExtensions = [
              pkgs.vscode-marketplace.bbenoist.nix
              pkgs.vscode-marketplace.vanyauhalin.moondusttheme
              pkgs.vscode-marketplace.esbenp.prettier-vscode
            ];
          })
          pkgs.iterm2
          pkgs.firefox-bin
          pkgs.thunderbird
          pkgs.reaper
          pkgs.ffmpeg
          # Tranismission should work, idk why it doesn't
          # pkgs.transmission_4-qt 
          pkgs.prismlauncher
          pkgs.deno
          pkgs.postgresql
          # TODO: Make this build on mac
          # pkgs.sfizz # Sound font loader
        ];

      # Homebrew packages
      homebrew = {
        enable = true;
        # Regular casks
        casks = [
          "github" # Github Desktop
          "shottr"
          "ente-auth"
          "signal"
          "vlc"
          "docker"
          "microsoft-powerpoint"
          "microsoft-excel"
          "microsoft-word"
          "qgis"
          "onedrive"
          "transmission"
          "scroll-reverser"
          "sf-symbols"
        ];
        # Regular homebrew cli tools
        brews = [
          "mas" # Utility for getting mac app store IDs
          "cloudflared"
          "node"
          "pnpm"
          "python"
          "docker-compose"
        ];
        # Mac app store apps
        masApps = {
          "r-101" = 1519963914;
          "Xcode" = 497799835;
        };
        onActivation.cleanup = "zap"; # delete everything that wasn't listed above
        # Autoupdate
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # MacOS settings
      system.defaults = {
        dock = {
          autohide = true;
          persistent-apps = [
            "${pkgs.firefox-bin}/Applications/Firefox.app"
            "${pkgs.thunderbird}/Applications/Thunderbird.app"
            "/Applications/Signal.app"
            "/Applications/Ente Auth.app"
            "${pkgs.iterm2}/Applications/iTerm2.app"
            "/System/Applications/Utilities/Activity Monitor.app"
            "/Applications/GitHub Desktop.app"
            "${pkgs.vscodium}/Applications/VSCodium.app"
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
        defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool "true"
        defaults write com.apple.AppleMultitouchTrackpad Clicking -bool "true" # tap-to-click
        defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 1 # hardness
        defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 2 # quick look
        defaults write com.apple.trackpad.forceClick -bool "false"

        # Keyboard
        defaults write com.apple.HIToolbox AppleFnUsageType -int "2" # make globe key show emoji picker

        # Menu bar
        defaults write com.apple.menuextra.clock ShowSeconds -bool "true"
        defaults write com.apple.controlcenter BatteryShowPercentage -bool "true"

        # Finder
        defaults write com.apple.finder "FXRemoveOldTrashItems" -bool "true" # Empty bin after 30 days
        defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"  # show file extensions
        defaults write com.apple.finder "AppleShowAllFiles" -bool "true" # Show hidden files
  
        # App minimise effect
        defaults write com.apple.dock "mineffect" -string "suck"

        # Make TextEdit use plain text
        defaults write com.apple.TextEdit "RichText" -bool "false"
        
        # Disable gatekeeper
        spctl --master-disable

        # Dock
        defaults write com.apple.dock "scroll-to-open" -bool "true"

        # Restart stuff
        killall ControlCenter || "true"
        killall SystemUIServer || "true"
        killall Finder || "true"
        killall Dock || "true"

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

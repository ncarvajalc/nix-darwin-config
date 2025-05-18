{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, mac-app-util, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
          pkgs.mkalias
          pkgs.fzf
        ];
      
      homebrew = {
        enable = true;
        brews = [
          "mas"
        ];
        casks = [
          # Desktop Apps
          "arc"
          "anydesk"
          "logi-options+"
          "chatgpt"
          "visual-studio-code"
          "cursor"
          "obsidian"
          "spotify"
          "docker"
          "orbstack"
          "google-chrome"
          # Utilities
          "rectangle"
          "maccy"
          "alt-tab"
          "raycast"
        ];
        masApps ={
          "WhatsApp" = 310633997;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      system.defaults = {
        dock = {
          autohide = true;
          show-recents = false;
          expose-group-apps = true;
          showhidden = true;
          tilesize = 60;

          persistent-apps = [
          "/System/Applications/Mail.app"
          "/Applications/Arc.app"
          "/Applications/Visual Studio Code.app"
          "/Applications/Cursor.app"
          "/Applications/Obsidian.app"
          "/System/Applications/Utilities/Terminal.app"
          "/Applications/WhatsApp.app"
          ];
        };
        finder = {
          AppleShowAllExtensions = true;
          ShowPathbar = true;
          ShowStatusBar = true;
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "clmv";
          _FXSortFoldersFirst = true;
          _FXSortFoldersFirstOnDesktop = true;
        };
        NSGlobalDomain = {
          KeyRepeat = 2;
          NSAutomaticQuoteSubstitutionEnabled = false;
          "com.apple.sound.beep.feedback" = 1;
        };
        WindowManager = {
          EnableTiledWindowMargins = false; 
        };
        controlcenter = {
          NowPlaying = false;
          Sound = true;
        };
        loginwindow = {
          PowerOffDisabledWhileLoggedIn = true;
          RestartDisabled = true;
          RestartDisabledWhileLoggedIn = true;
          ShutDownDisabled = true;
          ShutDownDisabledWhileLoggedIn = true;
        };
      };

      #Zsh config
      programs.zsh = {
        enable = true;
        enableFzfCompletion = true;
        enableFzfHistory = true;
        enableSyntaxHighlighting = true;
      };

      # Shell aliases 
      environment.shellAliases = {
        pgadmin-up ="docker run -d --name pgadmin --restart always -p 80:80 -e \"PGADMIN_DEFAULT_EMAIL=n.carvajalc@uniandes.edu.co\" -e \"PGADMIN_DEFAULT_PASSWORD=admin\" -v pgadmin_data:/var/lib/pgadmin dpage/pgadmin4";
      };

      # Networking
      networking.wakeOnLan.enable = true;

      # Auto upgrade nix package and the deamon service
      services.nix-daemon.enable = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      
      # Allow unfree packages instalation
      nixpkgs.config.allowUnfree = true;
    };

    homeconfig = {pkgs, ...}: {
      # this is internal compatibility configuration 
      # for home-manager, don't change this!
      home.stateVersion = "24.11";
      # Let home-manager install and manage itself.
      programs.home-manager.enable = true;

      home.packages = with pkgs; [];

      programs.git = {
        enable = true;
        userName = "Nicolás Carvajal";
        userEmail = "n.carvajalc@uniandes.edu.co";
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Mac-mini-de-Nicolas
    darwinConfigurations."Mac-mini-de-Nicolas" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            enable = true;
            # For Apple Silicon
            enableRosetta = true;
            # User owner of homebrew packages
            user = "nicolascarvajal";
          };
        }
        home-manager.darwinModules.home-manager {
          users.users.nicolascarvajal = {
            home = "/Users/nicolascarvajal";
          };
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.nicolascarvajal = homeconfig;
          };
        }
      ];
    };
  };
}

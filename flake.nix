{
  description = "Example nix-darwin system flake";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, mac-app-util, nix-homebrew }:
  let
    user = "nicolascarvajal"; # Change this to your username
    email = "n.carvajalc@uniandes.edu.co"; # Change this to your email
    name = "Nicolás Carvajal"; # Change this to your name
    home = "/Users/${user}"; # Change this to your home directory
    
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
          "pyenv"
          "libpq"
          "nvm"
          "pandoc"
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
          "microsoft-teams"
          "zoom"
          "slack"
          "virtualbox"
          # Fonts
          "font-montserrat"
          # Utilities
          "rectangle"
          "maccy"
          "alt-tab"
          "raycast"
          "amazon-q"
        ];
        masApps ={
          "WhatsApp" = 310633997;
          "Microsoft Excel" = 462058435;
          "Microsoft PowerPoint" = 462062816;
          "Microsoft Word" = 462054704;
          "Microsoft Outlook" = 985367838;
          "Hidden Bar" = 1452453066;
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
          "/Applications/Microsoft Outlook.app"
          "/Applications/Arc.app"
          "/Applications/Visual Studio Code.app"
          "/Applications/Cursor.app"
          "/Applications/Obsidian.app"
          "/System/Applications/Utilities/Terminal.app"
          "/Applications/WhatsApp.app"
          ];
          persistent-others = [
          "${home}/Downloads"
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

      # Enable watchIdAuth for sudo
      security.pam.services.sudo_local.watchIdAuth = true;

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

      # System primary user.
      system.primaryUser = user;

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
        userName = name;
        userEmail = email;
      };

      programs.zsh = {
        enable = true;

        history = {
          path = "${home}/.zsh_history";
          size = 100000;
          save = 100000;
          extended = true;
          share = true;
        };

        initContent = ''
          export HISTTIMEFORMAT="[%F %T] "
          setopt HIST_FIND_NO_DUPS
          setopt HIST_IGNORE_ALL_DUPS
          export PYENV_ROOT="$HOME/.pyenv"
          [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
          eval "$(pyenv init - zsh)"
          export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
          source $(brew --prefix nvm)/nvm.sh
        '';
      };
      
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#mac-mini
    darwinConfigurations."mac-mini" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            enable = true;
            # For Apple Silicon
            enableRosetta = true;
            # User owner of homebrew packages
            user = user;
          };
        }
        home-manager.darwinModules.home-manager {
          users.users.${user} = {
            home = home;
          };
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${user} = homeconfig;
          };
        }
      ];
    };
  };
}

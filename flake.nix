{
  description = "Nix darwin configuration for my personal Mac Minis";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.cl-nix-lite.url = "github:r4v3n6101/cl-nix-lite/url-fix";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager/master";
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
      mac-app-util,
      nix-homebrew,
      nix-vscode-extensions,
    }:
    let
      user = "nicolascarvajal"; # Change this to your username
      email = "n.carvajalc@uniandes.edu.co"; # Change this to your email
      name = "Nicolás Carvajal"; # Change this to your name
      home = "/Users/${user}"; # Change this to your home directory

      configuration =
        { pkgs, config, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.vim
            pkgs.mkalias
            pkgs.docker
            pkgs.fzf
            pkgs.nixfmt-rfc-style
            pkgs.gh
            pkgs.tree
            pkgs.uv
            pkgs.zoxide
            pkgs.starship
          ];

          homebrew = {
            enable = true;
            brews = [
              "mas"
              "pyenv"
              "libpq"
              "nvm"
              "pandoc"
              "ffmpeg"
              "openjdk@11"
              "tokei"
              "corkscrew"
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
              "orbstack"
              "google-chrome"
              "microsoft-teams"
              "zoom"
              "slack"
              "claude"
              "postman"
              "microsoft-azure-storage-explorer"
              "firefox"
              "spyder"
              "claude-code"
              "codex"
              # Fonts
              "font-montserrat"
              "font-jetbrains-mono-nerd-font"
              # Utilities
              "rectangle"
              "maccy"
              "alt-tab"
              "raycast"
              "meetingbar"
              "lookaway"
              "kiro-cli"
              "karabiner-elements"
              "ghostty"
            ];
            masApps = {
              "WhatsApp" = 310633997;
              "Microsoft Excel" = 462058435;
              "Microsoft PowerPoint" = 462062816;
              "Microsoft Word" = 462054704;
              "Microsoft Outlook" = 985367838;
              "Hidden Bar" = 1452453066;
              "Remote Desktop" = 1295203466;
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
                "/Applications/Ghostty.app"
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
              AppleShowAllExtensions = true;
              KeyRepeat = 2;
              NSAutomaticQuoteSubstitutionEnabled = false;
              "com.apple.sound.beep.feedback" = 1;
              AppleKeyboardUIMode = 2;
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
            screencapture = {
              location = "${home}/Desktop";
              type = "png";
            };
          };

          # Enable watchIdAuth for sudo
          security.pam.services.sudo_local.watchIdAuth = true;
          # Enable touchIdAuth for sudo
          security.pam.services.sudo_local.touchIdAuth = true;

          #Zsh config
          programs.zsh = {
            enable = true;
            enableFzfCompletion = true;
            enableFzfHistory = true;
            enableSyntaxHighlighting = true;
          };

          # Shell aliases
          environment.shellAliases = {
            pgadmin-up = "docker run -d --name pgadmin --restart always -p 80:80 -e \"PGADMIN_DEFAULT_EMAIL=n.carvajalc@uniandes.edu.co\" -e \"PGADMIN_DEFAULT_PASSWORD=admin\" -v pgadmin_data:/var/lib/pgadmin dpage/pgadmin4";
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

          # Add overlays for VSCode marketplace extensions
          nixpkgs.overlays = [
            nix-vscode-extensions.overlays.default
          ];
        };

      homeconfig =
        { pkgs, ... }:
        {
          # this is internal compatibility configuration
          # for home-manager, don't change this!
          home.stateVersion = "24.11";
          # Let home-manager install and manage itself.
          programs.home-manager.enable = true;

          home.packages = with pkgs; [ ];

          programs.git = {
            enable = true;
            settings = {
              user = {
                email = email;
                name = name;
              };
              init = {
                defaultBranch = "main";
              };
              pull = {
                rebase = true;
              };
            };
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
              export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
              export NVM_DIR="$HOME/.nvm"
              export PYENV_ROOT="$HOME/.pyenv"
              [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
              eval "$(pyenv init - zsh)"
              source $(brew --prefix nvm)/nvm.sh
            '';
          };

          programs.fzf = {
            enable = true;
            enableBashIntegration = true;
            enableZshIntegration = true;
          };

          # Zoxide config
          programs.zoxide = {
            enable = true;
            enableZshIntegration = true;
            options = [
              "--cmd cd"
            ];
          };

          # Starship config
          programs.starship = {
            enable = true;
            enableZshIntegration = true;
            settings = pkgs.lib.importTOML ./starship/starship.toml;
          };

          # Ghostty config
          xdg.enable = true;
          xdg.configFile."ghostty/config".source = ./ghostty/config;

          # VSCode config
          programs.vscode = {
            enable = true;
            profiles.default = {
              extensions = with pkgs.vscode-marketplace; [
                adpyke.codesnap
                alexcvzz.vscode-sqlite
                anthropic.claude-code
                catppuccin.catppuccin-vsc
                eamodio.gitlens
                esbenp.prettier-vscode
                formulahendry.auto-rename-tag
                github.vscode-pull-request-github
                grapecity.gc-excelviewer
                gruntfuggly.todo-tree
                janisdd.vscode-edit-csv
                jnoortheen.nix-ide
                jock.svg
                mechatroner.rainbow-csv
                meganrogge.template-string-converter
                mikestead.dotenv
                ms-ceintl.vscode-language-pack-es
                ms-vsliveshare.vsliveshare
                mutantdino.resourcemonitor
                mylesmurphy.prettify-ts
                naumovs.color-highlight
                pkief.material-icon-theme
                planbcoding.vscode-react-refactor
                qwtel.sqlite-viewer
                redhat.vscode-xml
                ritwickdey.liveserver
                shd101wyy.markdown-preview-enhanced
                steoates.autoimport
                streetsidesoftware.code-spell-checker
                streetsidesoftware.code-spell-checker-spanish
                tamasfe.even-better-toml
                tomoki1207.pdf
                wayou.vscode-todo-highlight
                yoavbls.pretty-ts-errors
              ];

              keybindings = [
                {
                  key = "ctrl+shift+[BracketLeft]";
                  command = "workbench.action.terminal.new";
                }
              ];

              userSettings = {
                # Visualization
                "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
                "workbench.iconTheme" = "material-icon-theme";
                "workbench.colorTheme" = "Catppuccin Mocha";
                # Preferences
                "editor.formatOnSave" = true;
                "terminal.integrated.scrollback" = 1000000000;
                "editor.unicodeHighlight.invisibleCharacters" = true;
                "editor.accessibilitySupport" = "off";
                "window.newWindowProfile" = "Default";
                # Git config
                "git.autofetch" = true;
                "git.openRepositoryInParentFolders" = "always";
              };
            };
          };

        };
    in
    {
      # Build darwin flake using:
      # When is the first time you set up nix-darwin on this machine, run:
      # sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .
      # After that, you can use the shorter command:
      # $ sudo darwin-rebuild switch --flake .
      darwinConfigurations."MBP-Nico" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          mac-app-util.darwinModules.default
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              # For Apple Silicon
              enableRosetta = true;
              # User owner of homebrew packages
              user = user;
              autoMigrate = true;
            };
          }
          home-manager.darwinModules.home-manager
          {
            users.users.${user} = {
              home = home;
            };
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = homeconfig;
              backupFileExtension = "old";
            };
          }
        ];
      };
    };
}

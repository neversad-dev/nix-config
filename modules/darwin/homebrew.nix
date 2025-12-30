{
  lib,
  config,
  ...
}: {
  homebrew = {
    enable = true;

    taps = [
      "nikitabobko/tap"
      "FelixKratz/formulae"
    ];

    onActivation = {
      autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
      upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      cleanup = "zap";
    };

    # `brew install`
    brews =
      [
        "git"
        "git-lfs"
        "wget" # download tool
        "curl" # no not install curl via nixpkgs, it's not working well on macOS!

        "borders"
        "imagemagick"
        "ffmpeg"
        "sketchybar"
      ]
      ++ lib.optionals config.development.flutter.enable [
        "cocoapods" # needed for Flutter
      ];

    # `brew install --cask`
    casks =
      [
        # terminal
        # "kitty"
        "ghostty"

        # browsers
        "firefox"
        "google-chrome"
        "zen"

        # messengers
        "signal"
        "slack"
        # "zoom"

        # media & files
        "iina"
        "localsend"
        "the-unarchiver"
        "transnomino" # A batch rename utility for the Mac
        "handbrake-app" # Open-source video transcoder available for Linux, Mac, and Windows
        "imageoptim" # Tool to optimise images to a smaller size
        "onlyoffice" # Document editor

        # productivity
        "raycast" # (HotKey: alt/option + space)search, calculate and run scripts(with many plugins)
        "aerospace"
        "alt-tab"
        "bettertouchtool"
        "itsycal"
        "obsidian" # Knowledge base that works on top of a local folder of plain text Markdown files

        # tools
        "stats" # beautiful system status monitor in menu bar
        "monitorcontrol"
        "balenaetcher"
        "rustdesk"

        # fonts
        "font-sf-pro"
        "sf-symbols"
      ]
      ++ lib.optionals config.development.cursor.enable [
        "cursor"
      ]
      ++ lib.optionals config.development.android.enable [
        "android-studio"
      ]
      ++ lib.optionals config.gaming.enable [
        "steam"
      ];

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps =
      {
        Bitwarden = 1352778147;
        PDFgear = 6469021132;
      }
      // lib.optionalAttrs config.stay-awake.enable {
        Amphetamine = 937984704;
      }
      // lib.optionalAttrs config.development.flutter.enable {
        # Xcode = 497799835;
      };
  };

  # Add Homebrew paths to the session path
  environment.systemPath = lib.mkBefore [
    "/usr/local/bin" # intel mac
    "/opt/homebrew/bin" # m1 mac
    "/opt/homebrew/sbin"
  ];
}

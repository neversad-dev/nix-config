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
    brews = [
      "git"
      "git-lfs" # git large file storage
      "wget" # download tool
      "curl" # no not install curl via nixpkgs, it's not working well on macOS!

      "borders"
      "imagemagick"

      {
        name = "sketchybar";
        start_service = true;
        restart_service = "changed";
      }
    ];

    # `brew install --cask`
    casks =
      [
        # terminal
        "kitty"
        "ghostty"

        # browsers
        "firefox"
        "google-chrome"
        "zen"

        # messengers
        "signal"

        # media & files
        "iina"
        "localsend"
        "the-unarchiver"
        "transnomino" # A batch rename utility for the Mac
        "handbrake" # Open-source video transcoder available for Linux, Mac, and Windows
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

        # fonts
        "font-sf-pro"
        "sf-symbols"

        # development
        "android-platform-tools"
        "android-file-transfer"
        "android-studio"
      ]
      ++ lib.optionals config.personal.enable [
        "cursor"
        "steam"
        "slack"
        "zoom"
      ];

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = {
      # Xcode = 497799835;
      #   wireguard = 1451685025;
      Bitwarden = 1352778147;
      PDFgear = 6469021132;
    };
  };

  # Add Homebrew paths to the session path
  environment.systemPath = lib.mkBefore [
    "/usr/local/bin" # intel mac
    "/opt/homebrew/bin" # m1 mac
    "/opt/homebrew/sbin"
  ];
}

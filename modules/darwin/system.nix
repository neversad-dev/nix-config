{pkgs, ...}:
###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#  Incomplete list of macOS `defaults` commands :
#    https://github.com/yannbertrand/macos-defaults
#
###################################################################################
{
  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  time.timeZone = "Europe/Kyiv";

  system = {
    # Set the primary user for system-wide configurations
    primaryUser = "neversad";

    # Proper system activation script
    activationScripts.extraActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      LaunchServices.LSQuarantine = false;
      # customize dock
      dock = {
        autohide = true;
        autohide-delay = 1.0;
        autohide-time-modifier = 0.0;
        launchanim = false;
        mineffect = "scale";
        mru-spaces = false;
        orientation = "left";
        persistent-apps = [];
        persistent-others = [];
        show-recents = false;
        tilesize = 10;

        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
      };

      # customize finder
      finder = {
        AppleShowAllExtensions = true; # show all file extensions
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
        FXPreferredViewStyle = "clmv";
        QuitMenuItem = true; # enable quit menu item
        ShowPathbar = true; # show path bar
        ShowStatusBar = true; # show status bar

        _FXShowPosixPathInTitle = true; # show full path in finder title
        _FXSortFoldersFirst = true;
      };

      # customize trackpad
      trackpad = {
        Clicking = true; # enable tap to click(Tapping the touchpad is equivalent to clicking)
        TrackpadRightClick = true; # enable two finger right click
        TrackpadThreeFingerDrag = true; # enable three finger drag
      };

      # customize settings that not supported by nix-darwin directly
      # Incomplete list of macOS `defaults` commands :
      #   https://github.com/yannbertrand/macos-defaults
      NSGlobalDomain = {
        AppleEnableMouseSwipeNavigateWithScrolls = false; # Enables swiping left or right with two fingers to navigate backward or forward
        AppleEnableSwipeNavigateWithScrolls = false; # Enables swiping left or right with two fingers to navigate backward or forward
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark"; # dark mode
        AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        ApplePressAndHoldEnabled = false; # enable press and hold. It will display a popup allowing you pick a special character
        AppleScrollerPagingBehavior = false; # Jump to the spot that's clicked on the scroll bar. The default is false.
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        AppleShowScrollBars = "Always"; # When to show the scrollbars. Options are 'WhenScrolling', 'Automatic' and 'Always'.
        AppleSpacesSwitchOnActivate = true; # Whether or not to switch to a workspace that has a window of the application open, that is switched to. The default is true.
        AppleTemperatureUnit = "Celsius";
        AppleWindowTabbingMode = "fullscreen"; # Sets the window tabbing when opening a new document: 'manual', 'always', or 'fullscreen'. The default is 'fullscreen'.
        # sets how long it takes before it starts repeating.
        InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
        # sets how fast it repeats once it starts.
        KeyRepeat = 2; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)

        NSAutomaticCapitalizationEnabled = false; # disable auto capitalization
        NSAutomaticDashSubstitutionEnabled = false; # disable auto dash substitution
        NSAutomaticInlinePredictionEnabled = false; # Whether to enable inline predictive text. The default is true.
        NSAutomaticPeriodSubstitutionEnabled = false; # disable auto period substitution
        NSAutomaticQuoteSubstitutionEnabled = false; # disable auto quote substitution
        NSAutomaticSpellingCorrectionEnabled = false; # disable auto spelling correction
        NSAutomaticWindowAnimationsEnabled = false; # Whether to animate opening and closing of windows and popovers. The default is true.
        NSDisableAutomaticTermination = false; # Whether to disable the automatic termination of inactive apps.
        NSDocumentSaveNewDocumentsToCloud = false; # Whether to save new documents to iCloud by default. The default is true.
        NSNavPanelExpandedStateForSaveMode = true; # expand save panel by default
        NSNavPanelExpandedStateForSaveMode2 = true;
        NSScrollAnimationEnabled = true;
        NSTableViewDefaultSizeMode = 2; # Sets the size of the finder sidebar icons: 1 (small), 2 (medium) or 3 (large). The default is 3.
        NSWindowShouldDragOnGesture = true;

        _HIHideMenuBar = true;
        "com.apple.mouse.tapBehavior" = 1; # Configures the trackpad tap behavior. Mode 1 enables tap to click.
        "com.apple.sound.beep.feedback" = 0; # disable beep sound when pressing volume up/down key
        "com.apple.swipescrolldirection" = true; # enable natural scrolling(default to true)
        "com.apple.trackpad.enableSecondaryClick" = true;
      };

      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

      WindowManager = {
        AppWindowGroupingBehavior = false;
        EnableStandardClickToShowDesktop = false;
        StandardHideDesktopIcons = true;
        StandardHideWidgets = true;
      };

      menuExtraClock = {
        IsAnalog = false;
        Show24Hour = true;
        ShowDate = 2; # 0 = When space allows 1 = Always 2 = Never
        ShowDayOfWeek = false;
        ShowSeconds = false;
      };

      screencapture = {
        location = "~/Pictures/screenshots";
        show-thumbnail = true;
        type = "png";
      };

      screensaver = {
        # Require password immediately after sleep or screen saver begins
        askForPassword = true;
        askForPasswordDelay = 0;
      };

      # true for Aerospace: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
      spaces.spans-displays = true; # false = each physical display has a separate space (Mac default) true = one space spans across all physical displays

      loginwindow = {
        GuestEnabled = false; # disable guest user
        SHOWFULLNAME = false; # show full name in login window
      };

      # universalaccess.reduceMotion = true;  # TODO causes error
      universalaccess.reduceTransparency = true;

      # Customize settings that not supported by nix-darwin directly
      # see the source code of this project to get more undocumented options:
      #    https://github.com/rgcr/m-cli
      #
      # All custom entries can be found by running `defaults read` command.
      # or `defaults read xxx` to read a specific domain.
      CustomUserPreferences = {
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "64" = {enabled = false;}; # ShowLaunchpad shortcut

            # Override Mission Controle with Control + K
            "32" = {
              enabled = true; # Enable the new binding
              value = {
                parameters = [107 40 1310720];
                type = "standard";
              };
            };

            # Override Application windows with Control + J
            "33" = {
              enabled = true; # Enable the new binding
              value = {
                parameters = [106 38 1310720];
                type = "standard";
              };
            };
          };
        };
      };
    };

    # keyboard settings is not very useful on macOS
    # the most important thing is to remap option key to alt key globally,
    # but it's not supported by macOS yet.
    keyboard = {
      enableKeyMapping = true; # enable key mapping so that we can use `option` as `control`

      # NOTE: do NOT support remap capslock to both control and escape at the same time
      remapCapsLockToControl = true; # remap caps lock to control, useful for emac users
      remapCapsLockToEscape = false; # remap caps lock to escape, udfsseful for vim users

      # swap left command and left alt
      # so it matches common keyboard layout: `ctrl | command | alt`
      #
      # disabled, caused only problems!
      swapLeftCommandAndLeftAlt = false;
    };
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  environment.shells = [
    pkgs.zsh
  ];

  # Set default shell for user
  users.users.neversad = {
    shell = pkgs.zsh;
  };

  # Fonts
  fonts.packages = with pkgs; [
    # icon fonts
    material-design-icons
    font-awesome
    sketchybar-app-font

    # nerdfonts
    # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/pkgs/data/fonts/nerdfonts/shas.nix
    # symbols icon only
    nerd-fonts.symbols-only
    # Characters
    nerd-fonts.fira-code
    nerd-fonts.iosevka
    nerd-fonts.meslo-lg
    nerd-fonts.hack
  ];
}

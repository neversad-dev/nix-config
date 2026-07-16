{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs;
    [
      imagemagick
      firefox
      google-chrome

      signal-desktop
      localsend
      handbrake
      onlyoffice-desktopeditors
      obsidian
    ]
    ++ lib.optionals config.features.development.cursor.enable [
      code-cursor
    ];
}

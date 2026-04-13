{
  pkgs,
  config,
  inputs,
  ...
}: {
  home.packages = with pkgs;
    [
      inputs.ghostty.packages.${pkgs.system}.default
      imagemagick
      firefox
      google-chrome

      signal-desktop
      localsend
      handbrake
      onlyoffice-desktopeditors
      obsidian
      bitwarden-desktop
    ]
    ++ lib.optionals config.features.development.cursor.enable [
      code-cursor
    ];
}

{
  pkgs,
  config,
  inputs,
  ...
}: {
  home.packages = with pkgs;
    [
      inputs.ghostty.packages.${pkgs.system}.default
      wget
      curl
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
    ++ lib.optionals config.personal.enable [
      code-cursor
    ];
}

{
  mylib,
  myvars,
  ...
}: {
  # import sub modules
  imports =
    (mylib.scanPaths ./.)
    ++ [
      ../common/home.nix
      ../common/core
      ../common/tui
      ../common/gui
    ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    homeDirectory = "/Users/${myvars.username}";
  };
}

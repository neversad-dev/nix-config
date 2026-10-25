{mylib, ...}: {
  imports = mylib.scanPaths ./.;

  programs.herdr = {
    enable = true;
    settings = {
      onboarding = false;
      theme = {
        name = "catppuccin";
      };
      ui = {
        sound = {
          enabled = false;
        };
        toast = {
          delivery = "system";
        };
        status_indicators = "symbols";
      };
      keys = {};
    };
  };
}

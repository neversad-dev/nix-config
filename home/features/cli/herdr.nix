{pkgs-unstable, ...}: {
  programs.herdr = {
    enable = true;
    package = pkgs-unstable.herdr;
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
      };
    };
  };
}

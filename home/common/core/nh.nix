{config, ...}: {
  home.sessionVariables = {
    # nix-community/nh#305
    NH_NO_CHECKS = "1";
  };

  programs = {
    # nix commands replacement utility - using pinned version above
    nh = {
      enable = true;
      flake = "${config.home.homeDirectory}/nixProjects/nix-config-private";
    };
  };
}

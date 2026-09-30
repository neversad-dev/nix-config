{
  config,
  lib,
  pkgs-unstable,
  ...
}:
with lib; let
  cfg = config.features.cli.git;
in {
  config = mkIf cfg.enable {
    programs.worktrunk = {
      enable = true;
      package = pkgs-unstable.worktrunk;
      enableZshIntegration = true;
      settings = {
        # Place worktrees as sibling directories for bare-repo layouts
        # e.g. myproject/.git → myproject/main, myproject/feature
        worktree-path = "{{ repo_path }}/../{{ branch | sanitize }}";
      };
    };
  };
}

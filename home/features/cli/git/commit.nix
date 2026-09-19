{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.git;
in {
  config = mkIf cfg.enable {
    programs.git = {
      settings = {
        commit = {
          template = "~/.config/git/message";
        };
        core = {
          hooksPath = "~/.config/git/hooks";
        };
        # signing = {
        #   key = "xxx";
        #   signByDefault = true;
        # };
      };
    };

    home.file = {
      # Points to the template file in the same directory as this nix file
      ".config/git/message".source = ./commit-template;

      # Points to the hook script in the same directory
      ".config/git/hooks/commit-msg" = {
        source = ./commit-msg;
        executable = true;
      };
    };
  };
}

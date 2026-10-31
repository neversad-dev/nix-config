{lib, ...}:
with lib; {
  config = {
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

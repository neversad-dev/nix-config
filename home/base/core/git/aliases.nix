{lib, ...}:
with lib; {
  config = {
    programs = {
      git.settings = {
        url = {
          "git@github.com:neversad-dev/" = {
            insteadOf = "nd:";
          };
          "git@github.com:" = {
            insteadOf = "gh:";
          };
          "ssh://git@github.com/neversad-dev" = {
            insteadOf = "https://github.com/neversad-dev";
          };
        };
      };

      zsh.shellAliases = {
        gs = "git status --short";
        gd = "git diff";
        gds = "git diff --staged";

        ga = "git add";
        gaa = "git add --all";
        gap = "git add --patch"; # y - stage; n - skip; s - split; e = edit

        gc = "git commit";
        gcm = "git commit -m";
        gca = "git commit --amend";

        gp = "git push";
        gu = "git pull";

        gl = "git log --graph --all --pretty=format:'%C(auto)%h %C(white) %an %ar %C(auto)%D%n%s%n' --abbrev-commit";
        gb = "git branch";

        gini = "git init";
        gcl = "git clone";
      };
    };
  };
}

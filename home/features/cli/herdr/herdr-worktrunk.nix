{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.herdr.settings.keys.command = [
    {
      key = "prefix+shift+g";
      type = "plugin_action";
      command = "worktrunk.open";
      description = "Worktree: switch / create from default branch";
    }
    {
      key = "prefix+shift+c";
      type = "plugin_action";
      command = "worktrunk.open-current";
      description = "Worktree: switch / create from current branch";
    }
    {
      key = "prefix+shift+r";
      type = "plugin_action";
      command = "worktrunk.open-with-remotes";
      description = "Worktree: switch / create from local or remote branches";
    }
    {
      key = "prefix+shift+d";
      type = "plugin_action";
      command = "worktrunk.remove";
      description = "Worktree: remove";
    }
    {
      key = "prefix+shift+m";
      type = "plugin_action";
      command = "worktrunk.merge";
      description = "Worktree: merge into the target branch";
    }
  ];

  xdg.dataFile."herdr/plugins/devashish2203/herdr-worktrunk".source = pkgs.herdr-worktrunk;

  # Declaratively link the worktrunk plugin during Home Manager activation
  home.activation.linkHerdrWorktrunkPlugin = lib.hm.dag.entryAfter ["linkGeneration"] ''
    HERDR_BIN="${config.programs.herdr.package}/bin/herdr"
    PLUGIN_PATH="${config.xdg.dataHome}/herdr/plugins/devashish2203/herdr-worktrunk"

    if [ -x "$HERDR_BIN" ] && [ -d "$PLUGIN_PATH" ]; then
      $DRY_RUN_CMD "$HERDR_BIN" plugin link "$PLUGIN_PATH"
    fi
  '';
}

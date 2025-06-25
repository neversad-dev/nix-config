{pkgs, ...}: let
  tmux-nerd-font-window-name =
    pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux-nerd-font-window-name";
      version = "v2.1.2";
      rtpFilePath = "tmux-nerd-font-window-name.tmux";
      src = pkgs.fetchFromGitHub {
        owner = "joshmedeski";
        repo = "tmux-nerd-font-window-name";
        rev = "2f5131f01b6cc052069211f6dce02c3fec564da2";
        sha256 = "sha256-bnlOAfdBv5Rg4z1hu1jtdx5oZ6kAZE40K4zqLxmyYQE=";
      };
    };
  tmux-git-autofetch =
    pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux-git-autofetch";
      version = "master";
      rtpFilePath = "git-autofetch.tmux";
      src = pkgs.fetchFromGitHub {
        owner = "thepante";
        repo = "tmux-git-autofetch";
        rev = "f1887ed0eb3f95e138394f401dd673144f9aa94c";
        sha256 = "0dwyy0p616syp2mm0qjsh9zn1sbs258lrqg85a0hwipxvcqpw6x0";
      };
    };
in {
  catppuccin = {
    tmux.enable = false; # load plugin separately for latest version
  };
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1; # start indexing windows at 1 instead of 0
    clock24 = true;
    escapeTime = 0;
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    newSession = false; # Automatically spawn a session if trying to attach and none are running.
    shortcut = "s"; # CTRL following by this key is used as the main shortcut.
    terminal = "tmux-256color";
    sensibleOnTop = false;
    secureSocket = false;
    plugins = with pkgs; [
      tmux-nerd-font-window-name
      tmux-git-autofetch
      {
        plugin = tmuxPlugins.catppuccin.overrideAttrs (_: {
          version = "v2.1.0";
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "tmux";
            rev = "d6458527ef121cc280c5dd119ba638749de1f713";
            hash = "sha256-kWixGC3CJiFj+YXqHRMbeShC/Tl+1phhupYAIo9bivE=";
          };
        });
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_status_background '#{E:@thm_surface_0}'

          # Menu styling options
          set -g @catppuccin_menu_selected_style "fg=#{@thm_surface_0},bg=#{@thm_yellow}"

          # Pane styling options
          set -g @catppuccin_pane_active_border_style "##{?pane_in_mode,fg=#{@thm_peach},##{?pane_synchronized,fg=#{@thm_red},fg=#{@thm_peach}}}"

          # Window styling
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_window_number_position "right"
          set -g @catppuccin_window_text_color "#{@thm_surface_1}"
          set -g @catppuccin_window_number_color "#{@thm_overlay_2}"

          set -g @catppuccin_window_text "#(${tmux-nerd-font-window-name}/share/tmux-plugins/tmux-nerd-font-window-name/bin/tmux-nerd-font-window-name  #{pane_current_command} #{window_panes})#T"
          set -g @catppuccin_window_current_text_color "#{@thm_surface_2}"
          set -g @catppuccin_window_current_number_color "#{@thm_peach}"
          set -g @catppuccin_window_current_text "#(${tmux-nerd-font-window-name}/share/tmux-plugins/tmux-nerd-font-window-name/bin/tmux-nerd-font-window-name  #{pane_current_command} #{window_panes})#T"
          set -g @catppuccin_window_flags "icon"
          set -g @catppuccin_window_flags_icon_last "" # -
          set -g @catppuccin_window_flags_icon_current "" # *
          set -g @catppuccin_window_flags_icon_zoom " 󰁌" # Z
          set -g @catppuccin_window_flags_icon_mark " 󰃀" # M
          set -g @catppuccin_window_flags_icon_silent " 󰂛" # ~
          set -g @catppuccin_window_flags_icon_activity " 󱅫" # #
          set -g @catppuccin_window_flags_icon_bell " 󰂞" # !

          # Status config
          set -g status-right-length 100
          set -g status-left-length 100
          set -g status-left "#{E:@catppuccin_status_session}"
          set -g status-right "#{E:@catppuccin_status_date_time}"

        '';
      }
      {
        plugin = tmuxPlugins.tmux-fzf;
        extraConfig = ''
          TMUX_FZF_LAUNCH_KEY="space"
        '';
      }
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.resurrect
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'off'
        '';
      }
    ];
    extraConfig = ''

      set -g status-position top

      # Increase tmux messages display duration from 750ms to 4s
      set -g display-time 4000

      # renumber all windows when any window is closed
      set-option -g renumber-windows on

      # easy-to-remember split pane commands
      bind | split-window -h -c "#{pane_current_path}"
      bind "\\" split-window -fh -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind _ split-window -fv -c "#{pane_current_path}"
      unbind '"'
      unbind %
      bind c new-window -c "#{pane_current_path}"

      # refresh configuration
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf
    '';
  };
}

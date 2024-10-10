{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "tinker";
  home.homeDirectory = "/Users/tinker";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  
  home.packages = with pkgs; [
    starship
    zsh-autosuggestions
    zsh-autocomplete
    zsh-syntax-highlighting
    fzf
    zoxide
    bat
    fd
    fzf-git-sh
    delta
    eza
    tlrc
    thefuck
  ];

  programs.zsh = {
    enable = true;
    # ohMyZsh.enable = false;  # Disable Oh My Zsh if you have it installed
    initExtra = ''
      # Initialize Starship prompt
      eval "$(starship init zsh)"

      # Source Zsh plugins
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.zsh-autocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      
      # Set up fzf key bindings and fuzzy completion
      eval "$(fzf --zsh)"

      export FZF_DEFAULT_OPTS=" \
      --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
      --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
      --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
      --color=selected-bg:#45475a \
      --multi"

      show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

      export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
      export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

      # Advanced customization of fzf options via _fzf_comprun function
      # - The first argument to the function is the name of the command.
      # - You should make sure to pass the rest of the arguments to fzf.
      _fzf_comprun() {
        local command=$1
        shift

        case "$command" in
          cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
          export|unset) fzf --preview "eval 'echo $${}'"         "$@" ;;
          ssh)          fzf --preview 'dig {}'                   "$@" ;;
          *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
        esac
      }

      # Set up zoxide for better cd
      eval "$(zoxide init --cmd cd zsh)"

      # -- Use fd instead of fzf --
      export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

      # Use fd (https://github.com/sharkdp/fd) for listing path candidates.
      # - The first argument to the function ($1) is the base path to start traversal
      # - See the source code (completion.{bash,zsh}) for the details.
      _fzf_compgen_path() {
        fd --hidden --exclude .git . "$1"
      }

      # Use fd to generate the list for directory completion
      _fzf_compgen_dir() {
        fd --type=d --hidden --exclude .git . "$1"
      }

      # bash and zsh key bindings for Git objects, powered by fzf.
      source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh

      # ---- Eza (better ls) -----
      alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"

      # thefuck alias
      eval $(thefuck --alias)
    '';

  };

  
  # Create a symlink for the starship.toml file
  home.file.".config/starship.toml".source = ../starship.toml;

  # Create a symlink for the kitty config
  home.file.".config/kitty".source = ../kitty;

  # Create a symlink for git files
  home.file.".gitignore".source = ../git/.gitignore;
  home.file.".gitconfig".source = ../git/.gitconfig;

  # Enable Starship
  programs.starship.enable = true;

  # Bat (better cat)
  home.file.".config/bat".source = ../bat;
}

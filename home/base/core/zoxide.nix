# Smarter cd: jump to frequent and recent directories (z/autojump-style)
{
  config,
  lib,
  ...
}: {
  options.features.cli.zoxide.enable = lib.mkEnableOption "zoxide smarter cd";

  config = lib.mkIf config.features.cli.zoxide.enable {
    programs.zoxide = {
      enable = true;
      options = [
        "--cmd cd"
      ];
    };
  };
}

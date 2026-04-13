# Interactive HTTPS proxy for debugging and capturing traffic (opt-in)
{
  config,
  lib,
  pkgs,
  ...
}: with lib; let
  cfg = config.features.cli.mitmproxy;
in {
  options.features.cli.mitmproxy.enable = mkEnableOption "mitmproxy (HTTPS debugging proxy)";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mitmproxy
    ];
  };
}

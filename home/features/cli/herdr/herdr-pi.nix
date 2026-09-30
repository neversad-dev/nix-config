{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.ai;
in {
  config = mkIf cfg.enable {
    # Declaratively install herdr Pi integration during Home Manager activation
    home.activation.herdrPiIntegration = lib.hm.dag.entryAfter ["linkGeneration"] ''
      HERDR_BIN="${config.programs.herdr.package}/bin/herdr"

      if [ -x "$HERDR_BIN" ]; then
        $DRY_RUN_CMD "$HERDR_BIN" integration install pi 2>/dev/null || true
      fi
    '';
  };
}

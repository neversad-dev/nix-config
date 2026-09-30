{
  config,
  lib,
  ...
}: {
  # Declaratively install herdr Pi integration during Home Manager activation
  home.activation.herdrPiIntegration = lib.hm.dag.entryAfter ["linkGeneration"] ''
    HERDR_BIN="${config.programs.herdr.package}/bin/herdr"
    PI_EXTENSION="$HOME/.pi/agent/extensions/herdr-agent-state.ts"

    if [ -x "$HERDR_BIN" ] && [ ! -f "$PI_EXTENSION" ]; then
      $DRY_RUN_CMD "$HERDR_BIN" integration install pi 2>/dev/null || true
    fi
  '';
}

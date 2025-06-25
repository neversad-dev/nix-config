{
  lib,
  pkgs,
  ...
}: {
  home.activation.sketchybar = lib.hm.dag.entryAfter ["writeBoundary"] "${pkgs.sketchybar}/bin/sketchybar --reload";

  home.file.".config/sketchybar".source = ./config;
}

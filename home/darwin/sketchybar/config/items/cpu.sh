#!/bin/bash
CPU=(
  update_freq=2
  icon.font="$FONT:Regular:16.0"
  icon=􀧓
  icon.color="$RED"
  background.color="$BG_SEC_COLR"
  script="$PLUGIN_DIR/cpu.sh"
  click_script="open -a 'Activity Monitor'"
  label.width=48
  label.align=right
  padding_left=12
)

sketchybar --add item cpu right \
  --set cpu "${CPU[@]}"

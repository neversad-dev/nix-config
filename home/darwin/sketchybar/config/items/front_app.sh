#!/bin/bash

FRONT_APP=(
  display=active
  script="$PLUGIN_DIR/front_app.sh"
  click_script="open -a 'Mission Control'"
  icon.background.drawing=on
  label.font="$FONT:Bold:14.0"
  label.color="$BG_PRI_COLR"
  label.padding_left=2
  background.color="$LAVENDER"
)

sketchybar --add item front_app left \
  --set front_app "${FRONT_APP[@]}" \
  --subscribe front_app front_app_switched

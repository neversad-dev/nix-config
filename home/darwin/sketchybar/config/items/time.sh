#!/bin/bash

TIME=(
  width=44
  update_freq=10
  icon.drawing=off
  label.align=center
  label.font="$FONT:Semibold:13.0"
  script="$PLUGIN_DIR/time.sh"
  click_script="$PLUGIN_DIR/zen.sh"

)

sketchybar --add item time right \
  --set time "${TIME[@]}"

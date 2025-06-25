#!/bin/bash

TIME=(
  width=64
  update_freq=10
  icon.drawing=off
  label.align=center
  script="$PLUGIN_DIR/time.sh"
  click_script="$PLUGIN_DIR/zen.sh"

)

sketchybar --add item time right \
  --set time "${TIME[@]}"

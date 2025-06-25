#!/bin/bash

VOLUME_SLIDER=(
  script="$PLUGIN_DIR/volume_slider.sh"
  updates=on
  label.drawing=off
  icon.drawing=off
  padding_left=0
  padding_right=0
  slider.highlight_color="$GREEN"
  slider.background.height=5
  slider.background.corner_radius=3
  slider.background.color="$DARK_WHITE"
  slider.knob=􀀁
  slider.knob.drawing=on
  slider.width=0
)

sketchybar --add slider volume_slider right \
  --set volume_slider "${VOLUME_SLIDER[@]}" \
  --subscribe volume_slider volume_change mouse.clicked

VOLUME_ICON=(
  icon.color="$GREEN"
  icon.width=28
  label.drawing=false
  icon.padding_left=2
  script="$PLUGIN_DIR/volume_icon.sh"
  click_script="$PLUGIN_DIR/volume_click.sh"
)

sketchybar --add item volume_icon right \
  --set volume_icon "${VOLUME_ICON[@]}" \
  --subscribe volume_icon volume_change

sketchybar --add bracket volume volume_icon volume_slider \
  --set volume background.color="$BG_SEC_COLR"

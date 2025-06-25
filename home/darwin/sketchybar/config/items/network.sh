#!/bin/bash
NETWORK=(
  update_freq=30
  icon.font="$FONT:Regular:16.0"
  icon=
  icon.width=30
  label.drawing=false
  icon.padding_left=4
  background.color="$BG_SEC_COLR"
  script="$PLUGIN_DIR/network.sh"
  click_script="open -b com.apple.systempreferences /System/Library/PreferencePanes/Network.prefPane"
  label.align=right
)


sketchybar --add item  network right \
  --set network "${NETWORK[@]}" \
  --subscribe network network_change


    
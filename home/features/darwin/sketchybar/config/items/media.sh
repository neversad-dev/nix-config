#!/bin/bash

MEDIA=(
  label.color="$PEACH"
  label.max_chars=50
  scroll_texts=on
  icon=􀑪
  display=2
  icon.color="$PEACH"
  background.drawing=off
  script="$PLUGIN_DIR/media.sh"
)

sketchybar --add item media center \
  --set media "${MEDIA[@]}" \
  --subscribe media media_change

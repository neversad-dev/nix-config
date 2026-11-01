#!/bin/bash

CALENDAR=(
  width=94
  update_freq=60
  icon=􀧞
  icon.drawing=off
  icon.color="$SKY"
  label.font="$FONT:Semibold:13.0"
  script="$PLUGIN_DIR/calendar.sh"
  click_script="open \"itsycal://date/now\""
)

sketchybar --add item calendar right \
  --set calendar "${CALENDAR[@]}" \
  --subscribe calendar system_woke

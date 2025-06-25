#!/bin/bash

CALENDAR=(
  update_freq=60
  icon=􀧞
  icon.drawing=on
  icon.color="$SKY"
  background.color="$BG_SEC_COLR"
  script="$PLUGIN_DIR/calendar.sh"
  click_script="open \"itsycal://date/now\""
)

sketchybar --add item calendar right \
  --set calendar "${CALENDAR[@]}" \
  --subscribe calendar system_woke

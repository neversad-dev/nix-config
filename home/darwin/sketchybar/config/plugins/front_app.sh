#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

AEROSPACE_FOCUSED_MONITOR_NO=$(/opt/homebrew/bin/aerospace list-workspaces --focused)
AEROSPACE_LIST_OF_WINDOWS_IN_FOCUSED_MONITOR=$(/opt/homebrew/bin/aerospace list-windows --workspace $AEROSPACE_FOCUSED_MONITOR_NO | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

if [ "$SENDER" = "front_app_switched" ]; then
  #echo name:$NAME INFO: $INFO SENDER: $SENDER, SID: $SID >> ~/aaaa
  sketchybar --set "$NAME" label="$INFO" icon.background.image="app.$INFO" icon.background.image.scale=0.6 icon.background.image.padding_left=6

  apps=$AEROSPACE_LIST_OF_WINDOWS_IN_FOCUSED_MONITOR
  icon_strip=""
  if [ "${apps}" != "" ]; then
    while read -r app
    do
      icon_strip+="$($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
    done <<< "${apps}"
  else
    icon_strip="—"
  fi
  sketchybar --animate sin 10 --set space.$AEROSPACE_FOCUSED_MONITOR_NO label="$icon_strip"
fi


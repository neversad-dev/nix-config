#!/usr/bin/env bash

AEROSPACE_FOCUSED_MONITOR=$(aerospace list-monitors --focused | awk '{print $1}')
AEROSAPCE_WORKSPACE_FOCUSED_MONITOR=$(aerospace list-workspaces --monitor focused --empty no)
AEROSPACE_EMPTY_WORKESPACE=$(aerospace list-workspaces --monitor focused --empty)

reload_workspace_icon() {
  apps=$(aerospace list-windows --workspace "$@" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

  icon_strip=""
  if [ "${apps}" != "" ]; then
    while read -r app; do
      icon_strip+="$("$CONFIG_DIR"/plugins/icon_map_fn.sh "$app")"
    done <<<"${apps}"
  else
    icon_strip="—"
  fi

  sketchybar --animate sin 10 --set space."$*" label="$icon_strip"
}

if [ "$SENDER" = "aerospace_workspace_change" ]; then

  reload_workspace_icon "$AEROSPACE_PREV_WORKSPACE"
  reload_workspace_icon "$AEROSPACE_FOCUSED_WORKSPACE"

  # current workspace space border color
  sketchybar --set space."$AEROSPACE_FOCUSED_WORKSPACE" \
    icon.highlight=on \
    label.highlight=on \
    background.border_width=1

  # prev workspace space border color
  sketchybar --set space."$AEROSPACE_PREV_WORKSPACE" \
    icon.highlight=off \
    label.highlight=off \
    background.border_width=0

  for i in $AEROSAPCE_WORKSPACE_FOCUSED_MONITOR; do
    sketchybar --set space."$i" display="$AEROSPACE_FOCUSED_MONITOR"
  done

  for i in $AEROSPACE_EMPTY_WORKESPACE; do
    sketchybar --set space."$i" display=0
  done

  sketchybar --set space."$AEROSPACE_FOCUSED_WORKSPACE" display="$AEROSPACE_FOCUSED_MONITOR"

fi

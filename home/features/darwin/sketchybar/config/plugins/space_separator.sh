#!/usr/bin/env bash

if [ "$SENDER" = "aerospace_mode_change" ]; then

  if [ -n "$AEROSPACE_MODE" ]; then
    sketchybar --set "$NAME" icon="[$AEROSPACE_MODE]" \
      --set "$NAME" icon.drawing=on
  else
    sketchybar --set "$NAME" icon.drawing=off
  fi

fi

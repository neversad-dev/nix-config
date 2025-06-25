#!/bin/bash

volume_change() {
  # shellcheck source=/dev/null
  source "$CONFIG_DIR/icons.sh"
  case $INFO in
  [6-9][0-9] | 100)
    ICON=$VOLUME_100
    ;;
  [3-5][0-9])
    ICON=$VOLUME_66
    ;;
  [1-2][0-9])
    ICON=$VOLUME_33
    ;;
  [1-9])
    ICON=$VOLUME_10
    ;;
  0)
    ICON=$VOLUME_0
    ;;
  *) ICON=$VOLUME_100 ;;
  esac

  sketchybar --set volume_icon label="$ICON" \
    --set "$NAME" slider.percentage="$INFO"

  # INITIAL_WIDTH="$(sketchybar --query $NAME | jq -r ".slider.width")"
  # if [ "$INITIAL_WIDTH" -eq "0" ]; then
  #   sketchybar --animate tanh 30 --set $NAME slider.width=$WIDTH
  # fi

  sleep 3

  # Check wether the volume was changed another time while sleeping
  FINAL_PERCENTAGE="$(sketchybar --query "$NAME" | jq -r ".slider.percentage")"
  if [ "$FINAL_PERCENTAGE" -eq "$INFO" ]; then
    sketchybar --animate tanh 30 --set "$NAME" slider.width=0 \
      --animate tanh 30 --set volume_slider padding_right=0
  fi
}

mouse_clicked() {
  osascript -e "set volume output volume $PERCENTAGE"
}

case "$SENDER" in
"volume_change")
  volume_change
  ;;
"mouse.clicked")
  mouse_clicked
  ;;
esac

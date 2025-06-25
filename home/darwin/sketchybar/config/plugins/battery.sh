#!/bin/bash

# shellcheck source=/dev/null
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo '[0-9]+%' | cut -d'%' -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case ${PERCENTAGE} in
9[0-9] | 100)
  ICON="$BATTERY_100_ICON"
  ICON_COLOR=$BATTERY_1
  ;;
[6-8][0-9])
  ICON="$BATTERY_75_ICON"
  ICON_COLOR=$BATTERY_2
  ;;
[3-5][0-9])
  ICON="$BATTERY_50_ICON"
  ICON_COLOR=$BATTERY_3
  ;;
[1-2][0-9])
  ICON="$BATTERY_25_ICON"
  ICON_COLOR=$BATTERY_4
  ;;
[0-9])
  ICON="$BATTERY_0_ICON"
  ICON_COLOR=$BATTERY_5
  ;;
esac

if [[ $CHARGING != "" ]]; then
  ICON="$BATTERY_BOLT_ICON"
  ICON_COLOR=$BATTERY_2
fi

sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%" icon.color="${ICON_COLOR}"

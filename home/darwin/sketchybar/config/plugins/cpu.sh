#!/bin/bash

# shellcheck source=/dev/null
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
CPU_INFO=$(ps -eo pcpu,user)
CPU_SYS=$(echo "$CPU_INFO" | grep -v "$(whoami)" | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")
CPU_USER=$(echo "$CPU_INFO" | grep "$(whoami)" | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")

CPU_PERCENT="$(echo "$CPU_SYS $CPU_USER" | awk '{printf "%.0f\n", ($1 + $2)*100}')"

case ${CPU_PERCENT} in
9[0-9] | 100)
  ICON="$CPU_FIRE_ICON"
  ICON_COLOR=$CPU_3
  ;;
[5-8][0-9])
  ICON="$CPU_ICON"
  ICON_COLOR=$CPU_3
  ;;
[2-4][0-9])
  ICON="$CPU_ICON"
  ICON_COLOR=$CPU_2
  ;;
[0-9] | 1[0-9])
  ICON="$CPU_ICON"
  ICON_COLOR=$CPU_1
  ;;
esac

sketchybar --set "$NAME" icon="$ICON" label="$CPU_PERCENT%" icon.color="${ICON_COLOR}"

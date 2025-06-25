#!/bin/bash

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

# shellcheck source=/dev/null
source "$CONFIG_DIR/icons.sh"

VOLUME=$(osascript -e "output volume of (get volume settings)")
MUTED=$(osascript -e "output muted of (get volume settings)")

if [[ $MUTED != "false" ]]; then
    ICON="$SOUND_MUT_ICON"
    VOLUME=0
else
    case ${VOLUME} in
    100) ICON="$SOUND_FUL_ICON" ;;
    [7-9][0-9]) ICON="$SOUND_HIG_ICON" ;;
    [3-6][0-9]) ICON="$SOUND_MID_ICON" ;;
    [1-2][0-9] | [1-9]) ICON="$SOUND_LOW_ICON" ;;
    *) ICON="$SOUND_MUT_ICON" ;;
    esac
fi

sketchybar -m \
    --set volume_icon icon="$ICON"

#!/bin/bash

POPUP_OFF="sketchybar --set apple.logo$1 popup.drawing=off"
POPUP_CLICK_SCRIPT="sketchybar --set apple.logo$1 popup.drawing=toggle"

APPLE_LOGO=(
  icon="$APPLE"
  display="$1"
  icon.color="$WHITE"
  icon.padding_left=4
  label.drawing=off
  background.padding_left=0
  background.padding_right=22
  click_script="$POPUP_CLICK_SCRIPT; sleep 4; $POPUP_OFF"
  popup.height=35
)

APPLE_PREFS=(
  icon="$PREFERENCES"
  label="Preferences"
  click_script="open -a 'System Preferences'; $POPUP_OFF"
)

APPLE_ACTIVITY=(
  icon="$ACTIVITY"
  label="Activity"
  click_script="open -a 'Activity Monitor'; $POPUP_OFF"
)

APPLE_LOCK=(
  icon="$LOCK"
  label="Lock Screen"
  click_script="pmset displaysleepnow; open -a ScreenSaverEngine; $POPUP_OFF"
)

sketchybar --add item apple.logo"$1" left \
  --set apple.logo"$1" "${APPLE_LOGO[@]}"

sketchybar --add item apple.prefs"$1" popup.apple.logo"$1" \
  --set apple.prefs"$1" "${APPLE_PREFS[@]}"

sketchybar --add item apple.activity"$1" popup.apple.logo"$1" \
  --set apple.activity"$1" "${APPLE_ACTIVITY[@]}"

sketchybar --add item apple.lock"$1" popup.apple.logo"$1" \
  --set apple.lock"$1" "${APPLE_LOCK[@]}"

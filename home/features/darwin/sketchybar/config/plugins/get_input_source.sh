#!/bin/bash

# Read the plist data
plist_data=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources)
current_input_source=$(echo "$plist_data" | plutil -convert xml1 -o - - | grep -A1 'KeyboardLayout Name' | tail -n1 | cut -d '>' -f2 | cut -d '<' -f1)

if [ "$current_input_source" = "ABC" ] || [ "$current_input_source" = "U.S." ]; then
    sketchybar --set input_source icon="󱌯"
else
    sketchybar --set input_source icon="🇺🇦"
fi

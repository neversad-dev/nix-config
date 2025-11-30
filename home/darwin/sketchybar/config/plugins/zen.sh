#!/bin/bash

zen_on() {
  sketchybar --set wifi drawing=off \
    --set '/apple.logo.*/' drawing=off \
    --set '/cpu.*/' drawing=off \
    --set calendar drawing=off \
    --set battery drawing=off \
    --set space_separator drawing=off \
    --set front_app drawing=off \
    --set volume drawing=off \
    --set volume_icon drawing=off \
    --set volume_slider drawing=off \
    --set media drawing=off \
    --set "Control Center,CombinedModules" drawing=off
}

zen_off() {
  sketchybar --set wifi drawing=on \
    --set '/apple.logo.*/' drawing=on \
    --set '/cpu.*/' drawing=on \
    --set calendar drawing=on \
    --set battery drawing=on \
    --set space_separator drawing=on \
    --set front_app drawing=on \
    --set volume drawing=on \
    --set volume_icon drawing=on \
    --set volume_slider drawing=on \
    --set media drawing=on \
    --set "Control Center,CombinedModules" drawing=on
}

if [ "$1" = "on" ]; then
  zen_on
elif [ "$1" = "off" ]; then
  zen_off
else
  if [ "$(sketchybar --query apple.logo1 | jq -r ".geometry.drawing")" = "on" ]; then
    zen_on
  else
    zen_off
  fi
fi

#!/bin/bash

sketchybar --add alias "Control Center,CombinedModules" right \
    --set "Control Center,CombinedModules" click_script="open -a 'Activity Monitor'" \
    --set "Control Center,CombinedModules" background.padding_right=0 \
    --set "Control Center,CombinedModules" background.padding_left=0 \
    --set "Control Center,CombinedModules" label.padding_right=0 \
    --set "Control Center,CombinedModules" label.padding_left=0 \
    --set "Control Center,CombinedModules" icon.padding_right=0 \
    --set "Control Center,CombinedModules" icon.padding_left=0

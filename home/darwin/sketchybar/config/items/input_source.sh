#!/bin/bash

INPUT_SOURCE=(
    update_freq=1
    width=12
    icon.font="$FONT:Regular:16.0"
    icon.padding_left=0
    icon.padding_right=2
    label.drawing=off
    background.padding_right=0
    background.padding_left=0
    script="$PLUGIN_DIR/get_input_source.sh"
)

sketchybar --add item input_source right \
    --set input_source "${INPUT_SOURCE[@]}"

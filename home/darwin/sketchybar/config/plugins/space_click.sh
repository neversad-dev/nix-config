#!/usr/bin/env bash

AEROSPACE_CURRENT_WORKSPACE=$(aerospace list-workspaces --focused)

if [ "$SID" = "$AEROSPACE_CURRENT_WORKSPACE" ]; then
    FOCUSED_APP=$(aerospace list-windows --focused --format '%{window-id}')
    APPS=$(aerospace list-windows --workspace focused --format '%{window-id}')
    APPS_ARRAY=($APPS)

    if [[ ${#APPS_ARRAY[@]} -gt 1 ]]; then

        for i in "${!APPS_ARRAY[@]}"; do
            if [[ "${APPS_ARRAY[i]}" == "$FOCUSED_APP" ]]; then
                FOCUSED_INDEX=$i
                break
            fi
        done
        if [[ $FOCUSED_INDEX -ge 0 ]]; then
            NEXT_INDEX=$(((FOCUSED_INDEX + 1) % ${#APPS_ARRAY[@]}))
            NEXT_APP=${APPS_ARRAY[$NEXT_INDEX]}
            aerospace focus --window-id "$NEXT_APP"
        fi
    fi
else
    aerospace workspace "$SID"
fi

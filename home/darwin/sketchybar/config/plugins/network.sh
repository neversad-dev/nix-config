#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"


CURRENT_WIFI="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)"
SSID="$(echo "$CURRENT_WIFI" | grep -o "SSID: .*" | sed 's/^SSID: //')"
CURR_TX="$(echo "$CURRENT_WIFI" | grep -o "lastTxRate: .*" | sed 's/^lastTxRate: //')"

IP_ADDRESS=$(scutil --nwi | grep address | sed 's/.*://' | tr -d ' ' | head -1)

if [[ $IP_ADDRESS != "" ]]; then
	COLOR=$BLUE
	ICON=$WIFI_ICON
	LABEL="$SSID: $IP_ADDRESS"
else
	COLOR=$RED
	ICON=$WIFI_DISCONNECTED_ICON
	LABEL="Not Connected"
fi

sketchybar --set $NAME \
    icon.color=$COLOR \
	icon=$ICON \
	label="$LABEL"
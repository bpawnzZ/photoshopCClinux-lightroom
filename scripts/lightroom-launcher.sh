#!/usr/bin/env bash
# Lightroom-only launcher

SCR_PATH="pspath"
CACHE_PATH="pscache"

RESOURCES_PATH="$SCR_PATH/resources"
WINE_PREFIX="$SCR_PATH/prefix"

export WINEPREFIX="$WINE_PREFIX"

# Launch Lightroom
if [ -f "$RESOURCES_PATH/lightroomCC/LightroomSE/Lightroom.8/LightroomPortable.exe" ]; then
    # Try to use Lightroom icon if available, otherwise use generic icon
    if [ -f "$SCR_PATH/launcher/lightroom.png" ]; then
        notify-send "Lightroom CC" "Lightroom CC launched." -i "$SCR_PATH/launcher/lightroom.png"
    else
        notify-send "Lightroom CC" "Lightroom CC launched." -i "lightroom"
    fi
    wine "$RESOURCES_PATH/lightroomCC/LightroomSE/Lightroom.8/LightroomPortable.exe"
else
    echo "Lightroom not found."
    echo "Expected at: $RESOURCES_PATH/lightroomCC/LightroomSE/Lightroom.8/LightroomPortable.exe"
    exit 1
fi
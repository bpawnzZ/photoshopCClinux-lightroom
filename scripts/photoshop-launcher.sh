#!/usr/bin/env bash
# Photoshop-only launcher

SCR_PATH="pspath"
CACHE_PATH="pscache"

RESOURCES_PATH="$SCR_PATH/resources"
WINE_PREFIX="$SCR_PATH/prefix"

export WINEPREFIX="$WINE_PREFIX"

# Launch Photoshop
if [ -f "$SCR_PATH/prefix/drive_c/users/$USER/PhotoshopSE/Photoshop.exe" ]; then
    # Try to use Photoshop icon if available, otherwise use generic icon
    if [ -f "$SCR_PATH/launcher/AdobePhotoshop-icon.png" ]; then
        notify-send "Photoshop CC" "Photoshop CC launched." -i "$SCR_PATH/launcher/AdobePhotoshop-icon.png"
    else
        notify-send "Photoshop CC" "Photoshop CC launched." -i "photoshop"
    fi
    wine "$SCR_PATH/prefix/drive_c/users/$USER/PhotoshopSE/Photoshop.exe"
else
    echo "Photoshop not found."
    echo "Expected at: $SCR_PATH/prefix/drive_c/users/$USER/PhotoshopSE/Photoshop.exe"
    exit 1
fi

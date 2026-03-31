#!/usr/bin/env bash
if [ $# -ne 0 ];then
    echo "I have no parameters just run the script without arguments"
    exit 1
fi

SCR_PATH="pspath"
CACHE_PATH="pscache"

RESOURCES_PATH="$SCR_PATH/resources"
WINE_PREFIX="$SCR_PATH/prefix"

export WINEPREFIX="$WINE_PREFIX"

# Check for Lightroom first (portable)
if [ -f "$RESOURCES_PATH/lightroomCC/LightroomSE/Lightroom.8/LightroomPortable.exe" ]; then
    # Try to use Lightroom icon if available, otherwise use generic icon
    if [ -f "$SCR_PATH/launcher/lightroom.png" ]; then
        notify-send "Lightroom CC" "Lightroom CC launched." -i "$SCR_PATH/launcher/lightroom.png"
    else
        notify-send "Lightroom CC" "Lightroom CC launched." -i "lightroom"
    fi
    wine "$RESOURCES_PATH/lightroomCC/LightroomSE/Lightroom.8/LightroomPortable.exe"
# Then check for Photoshop
elif [ -f "$SCR_PATH/prefix/drive_c/users/$USER/PhotoshopSE/Photoshop.exe" ]; then
    # Try to use Photoshop icon if available, otherwise use generic icon
    if [ -f "$SCR_PATH/launcher/AdobePhotoshop-icon.png" ]; then
        notify-send "Photoshop CC" "Photoshop CC launched." -i "$SCR_PATH/launcher/AdobePhotoshop-icon.png"
    else
        notify-send "Photoshop CC" "Photoshop CC launched." -i "photoshop"
    fi
    wine "$SCR_PATH/prefix/drive_c/users/$USER/PhotoshopSE/Photoshop.exe"
else
    echo "No Adobe application found to launch"
    exit 1
fi

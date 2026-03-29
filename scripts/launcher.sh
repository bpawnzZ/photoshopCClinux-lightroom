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
    notify-send "Lightroom CC" "Lightroom CC launched." -i "lightroom"
    wine "$RESOURCES_PATH/lightroomCC/LightroomSE/Lightroom.8/LightroomPortable.exe"
# Then check for Photoshop
elif [ -f "$SCR_PATH/prefix/drive_c/users/$USER/PhotoshopSE/Photoshop.exe" ]; then
    notify-send "Photoshop CC" "Photoshop CC launched." -i "photoshopicon"
    wine "$SCR_PATH/prefix/drive_c/users/$USER/PhotoshopSE/Photoshop.exe"
else
    echo "No Adobe application found to launch"
    exit 1
fi

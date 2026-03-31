#!/usr/bin/env bash
function main() {
    
    source "sharedFuncs.sh"

    load_paths
    WINE_PREFIX="$SCR_PATH/prefix"

    #resources will be remove after installation
    RESOURCES_PATH="$SCR_PATH/resources"

    check_ps_installed
    
    export_var
    install_cameraRaw
}

function check_ps_installed() {
    ([ -d "$SCR_PATH" ] && [ -d "$CACHE_PATH" ] && [ -d "$WINE_PREFIX" ] && show_message2 "photoshop installed") || error2 "photoshop not found you should intsall photoshop first"
}

function install_cameraRaw() {
    local filename="CameraRaw_12_2_1.exe"
    local filemd5="b6a6b362e0c159be5ba1d0eb1ebd0054"
    local filelink="https://download.adobe.com/pub/adobe/photoshop/cameraraw/win/12.x/CameraRaw_12_2_1.exe"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local filepath="$script_dir/../files/$filename"

    # Use local file if exists, otherwise download
    if [ ! -f "$filepath" ]; then
        filepath="$CACHE_PATH/$filename"
        download_component $filepath $filemd5 $filelink $filename
    fi

    echo "===============| Adobe Camera Raw v12 |===============" >> "$SCR_PATH/wine-error.log"
    show_message "Adobe Camera Raw v12 installation..."

    # Run Camera Raw installer with timeout to prevent hanging
    # Give it 3 minutes (180 seconds) to complete installation
    timeout 180 wine "$filepath" &>> "$SCR_PATH/wine-error.log"
    
    # Check if timeout occurred
    local exit_code=$?
    if [ $exit_code -eq 124 ]; then
        warning "Camera Raw installer timed out after 3 minutes. It may have completed or need manual intervention."
        warning "Checking if Camera Raw was installed..."
    elif [ $exit_code -ne 0 ]; then
        warning "Camera Raw installer exited with code $exit_code. Checking if installation was successful anyway..."
    fi
    
    # Kill any running Camera Raw or Adobe processes
    show_message "Stopping any running Adobe processes..."
    pkill -f "CameraRaw" 2>/dev/null || true
    pkill -f "Adobe" 2>/dev/null || true
    
    # Wait a moment for processes to terminate
    sleep 2

    notify-send "Photoshop CC" "Adobe Camera Raw v12 installed successfully" -i "photoshop"
    show_message "Adobe Camera Raw v12 installed..."
    unset filename filemd5 filelink filepath
}

main

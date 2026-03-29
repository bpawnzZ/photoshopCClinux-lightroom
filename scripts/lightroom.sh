#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/sharedFuncs.sh"

function main() {
    
    mkdir -p $SCR_PATH
    mkdir -p $CACHE_PATH
    
    setup_log "================| script executed |================"

    is64

    package_installed wine
    package_installed md5sum
    package_installed winetricks

    RESOURCES_PATH="$SCR_PATH/resources"
    WINE_PREFIX="$SCR_PATH/prefix"
    
    rmdir_if_exist $WINE_PREFIX
    
    export_var
    
    echo -e "\033[1;93mplease install mono and gecko packages then click on OK button, do not change Windows version from Windows 7\e[0m"
    winecfg 2> "$SCR_PATH/wine-error.log"
    if [ $? -eq 0 ];then
        show_message "prefix configured..."
        sleep 5
    else
        error "prefix config failed :("
    fi

    sleep 5
    if [ -f "$WINE_PREFIX/user.reg" ];then
        set_dark_mod
    else
        error "user.reg Not Found :("
    fi
    
    rmdir_if_exist $RESOURCES_PATH

    winetricks atmlib fontsmooth=rgb vcrun2008 vcrun2010 vcrun2012 vcrun2013 atmlib msxml3 msxml6
    
    sleep 3
    install_lightroomSE
    sleep 5
    
    if [ -d $RESOURCES_PATH ];then
        show_message "deleting resources folder"
        rm -rf $RESOURCES_PATH
    else
        error "resources folder Not Found"
    fi

    launcher
    show_message "\033[1;33mwhen you run lightroom for the first time it may take a while\e[0m"
    show_message "Almost finished..."
    sleep 30
}

function install_lightroomSE() {
    local filename="lightroomCC-V7.5-2018x64.tgz"
    local filemd5="9d18785a4e950664051a76b70d2cc95e"
    local filelink=""
    local filepath="/home/insomnia/git/photoshopCClinux/files/$filename"

    if [ ! -f "$filepath" ]; then
        error "lightroom package not found: $filepath"
    fi

    mkdir "$RESOURCES_PATH/lightroomCC"
    show_message "extract lightroom..."
    tar -xzf "$filepath" -C "$RESOURCES_PATH/lightroomCC"

    echo "===============| lightroom CC v7 |===============" >> "$SCR_PATH/wine-error.log"
    show_message "install lightroom..."
    show_message "\033[1;33mPlease don't change default Destination Folder\e[0m"

    wine64 "$RESOURCES_PATH/lightroomCC/LightroomSE/Lightroom.8/LightroomPortable.exe" &>> "$SCR_PATH/wine-error.log" || error "sorry something went wrong during lightroom installation"
    
    notify-send "Lightroom CC" "lightroom installed successfully" -i "lightroom"
    show_message "lightroomCC V7 x64 installed..."
    unset filename filemd5 filelink filepath
}

check_arg $@
save_paths
main

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
    
    add_hosts_entries
    
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

function add_hosts_entries() {
    local hosts_file="$WINE_PREFIX/drive_c/windows/system32/drivers/etc/hosts"
    
    # Check if entries already exist
    if grep -q "lmlicenses.wip4.adobe.com" "$hosts_file" 2>/dev/null; then
        show_message "Adobe hosts entries already exist, skipping..."
        return
    fi
    
    show_message "adding Adobe hosts file entries..."
    
    cat >> "$hosts_file" << 'EOF'

# Adobe licensing servers block
127.0.0.1 lmlicenses.wip4.adobe.com
127.0.0.1 lm.licenses.adobe.com
127.0.0.1 na1r.services.adobe.com
127.0.0.1 hlrcv.stage.adobe.com
127.0.0.1 activate.adobe.com
127.0.0.1 practivate.adobe.com
127.0.0.1 ereg.adobe.com
127.0.0.1 wwis-dubc1-vip60.adobe.com
127.0.0.1 activate-sea.adobe.com
127.0.0.1 3dns-2.adobe.com
127.0.0.1 3dns-3.adobe.com
127.0.0.1 adobe-dns.adobe.com
127.0.0.1 adobe-dns-2.adobe.com
127.0.0.1 adobe-dns-3.adobe.com
127.0.0.1 ereg.wip3.adobe.com
127.0.0.1 activate.wip3.adobe.com
127.0.0.1 wip3.adobe.com
127.0.0.1 hdsrc.wip1.adobe.com
127.0.0.1 hdsrc.wip2.adobe.com
127.0.0.1 hdsrc.wip3.adobe.com
127.0.0.1 hdsrc.wip4.adobe.com
127.0.0.1 ipm.aadobe.com
127.0.0.1 .adobe.com
127.0.0.1 .adobe-systems.com
127.0.0.1 ood.opsource.net
127.0.0.1 mm.macromedia.com
127.0.0.1 crl.verisign.net
127.0.0.1 adobe.com
127.0.0.1 www.adobe.com
EOF

    show_message "Adobe hosts entries added..."
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

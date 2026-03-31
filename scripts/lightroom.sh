#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/sharedFuncs.sh"

function main() {
    
    mkdir -p "$SCR_PATH"
    mkdir -p "$CACHE_PATH"
    
    setup_log "================| script executed |================"

    is64

    package_installed wine
    package_installed md5sum
    package_installed winetricks

    RESOURCES_PATH="$SCR_PATH/resources"
    WINE_PREFIX="$SCR_PATH/prefix"
    
    # Check if Lightroom is already installed
    if [ "$(check_adobe_app_installed lightroom)" = "true" ]; then
        show_message "Lightroom is already installed in this Wine prefix!"
        ask_question "Reinstall Lightroom?" "N"
        if [ "$question_result" = "no" ]; then
            show_message "Skipping Lightroom installation..."
            exit 0
        fi
    fi
    
    export_var
    
    # Create directories safely (don't delete if they exist)
    safe_create_dir "$RESOURCES_PATH"
    
    # Install missing dependencies (checks if prefix exists, creates if not)
    install_missing_dependencies "Lightroom CC"
    
    sleep 3
    install_lightroomSE
    sleep 5
    
    add_hosts_entries

    # Lightroom is portable - keep it in resources directory
    # Don't delete resources folder for Lightroom installation
    show_message "Lightroom portable files kept in: $RESOURCES_PATH/lightroomCC/"
    
    # Verify Lightroom files exist
    if [ -f "$RESOURCES_PATH/lightroomCC/LightroomSE/Lightroom.8/LightroomPortable.exe" ]; then
        show_message "Lightroom portable installation verified"
    else
        error "Lightroom portable files not found after installation"
    fi

    launcher lightroom
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
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local filepath="$script_dir/../files/$filename"

    if [ ! -f "$filepath" ]; then
        error "lightroom package not found: $filepath"
    fi

    mkdir -p "$RESOURCES_PATH/lightroomCC"
    show_message "extract lightroom..."
    tar -xzf "$filepath" -C "$RESOURCES_PATH/lightroomCC"

    echo "===============| lightroom CC v7 |===============" >> "$SCR_PATH/wine-error.log"
    show_message "install lightroom..."
    show_message "\033[1;33mPlease don't change default Destination Folder\e[0m"
    
    # Lightroom is now extracted. First launch will happen via desktop icon.
    show_message "Lightroom extracted successfully. First launch will occur via desktop icon."
    
    # Clean up any other Lightroom processes
    pkill -f "LightroomPortable.exe" 2>/dev/null || true
    pkill -f "Lightroom.exe" 2>/dev/null || true
    
    notify-send "Lightroom CC" "lightroom installed successfully" -i "lightroom"
    show_message "lightroomCC V7 x64 installed..."
    unset filename filemd5 filelink filepath
}

check_arg $@
save_paths
main

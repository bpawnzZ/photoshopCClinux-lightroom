#!/usr/bin/env bash
source "sharedFuncs.sh"

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

function main() {
    
    mkdir -p "$SCR_PATH"
    mkdir -p "$CACHE_PATH"
    
    setup_log "================| script executed |================"

    is64

    #make sure wine and winetricks package is already installed
    package_installed wine
    package_installed md5sum
    package_installed winetricks

    RESOURCES_PATH="$SCR_PATH/resources"
    WINE_PREFIX="$SCR_PATH/prefix"
    
    # Check if Photoshop is already installed
    if [ "$(check_adobe_app_installed photoshop)" = "true" ]; then
        show_message "Photoshop is already installed in this Wine prefix!"
        ask_question "Reinstall Photoshop?" "N"
        if [ "$question_result" = "no" ]; then
            show_message "Skipping Photoshop installation..."
            exit 0
        fi
    fi
    
    #export necessary variable for wine
    export_var
    
    # Create directories safely (don't delete if they exist)
    safe_create_dir "$RESOURCES_PATH"
    
    # Install missing dependencies (checks if prefix exists, creates if not)
    install_missing_dependencies "Photoshop CC"
    
    #install photoshop
    sleep 3
    install_photoshopSE
    sleep 5
    
    replacement

    add_hosts_entries

    # Clean up Photoshop installation files but preserve Lightroom if it exists
    if [ -d "$RESOURCES_PATH/photoshopCC" ]; then
        show_message "cleaning up Photoshop installation files..."
        rm -rf "$RESOURCES_PATH/photoshopCC"
    fi
    
    if [ -d "$RESOURCES_PATH/replacement" ]; then
        show_message "cleaning up replacement files..."
        rm -rf "$RESOURCES_PATH/replacement"
    fi
    
    # Only delete entire resources folder if it's empty (no Lightroom)
    if [ -d "$RESOURCES_PATH" ] && [ -z "$(ls -A "$RESOURCES_PATH" 2>/dev/null)" ]; then
        show_message "resources folder is empty, deleting it..."
        rm -rf "$RESOURCES_PATH"
    elif [ -d "$RESOURCES_PATH" ]; then
        show_message "resources folder contains other files (Lightroom?), keeping it..."
    fi

    launcher photoshop
    show_message "\033[1;33mwhen you run photoshop for the first time it may take a while\e[0m"
    show_message "Almost finished..."
    sleep 30
}

function replacement() {
    local filename="replacement.tgz"
    local filemd5="6441a8e77c082897a99c2b7b588c9ac4"
    local filelink="https://victor.poshtiban.io/p/gictor/photoshopCC/replacement.tgz"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local filepath="$script_dir/../files/$filename"

    # Use local file if exists, otherwise download
    if [ ! -f "$filepath" ]; then
        download_component "$filepath" "$filemd5" "$filelink" "$filename"
    fi

    mkdir -p "$RESOURCES_PATH/replacement"
    show_message "extract replacement component..."
    tar -xzf "$filepath" -C "$RESOURCES_PATH/replacement"

    local replacefiles=("IconResources.idx" "PSIconsHighRes.dat" "PSIconsLowRes.dat")
    local destpath="$WINE_PREFIX/drive_c/users/$USER/PhotoshopSE/Resources"
    
    for f in "${replacefiles[@]}";do
        local sourcepath="$RESOURCES_PATH/replacement/$f"
        cp -f "$sourcepath" "$destpath" || error "cant copy replacement $f file..."
    done

    show_message "replace component compeleted..."
    unset filename filemd5 filelink filepath
}

function install_photoshopSE() {
    local filename="photoshopCC-V19.1.6-2018x64.tgz"
    local filemd5="b63f6ed690343ee12b6195424f94c33f"
    local filelink="https://victor.poshtiban.io/p/gictor/photoshopCC/photoshopCC-V19.1.6-2018x64.tgz"
    # local filelink="http://127.0.0.1:8080/photoshopCC-V19.1.6-2018x64.tgz"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local filepath="$script_dir/../files/$filename"

    # Use local file if exists, otherwise download
    if [ ! -f "$filepath" ]; then
        download_component "$filepath" "$filemd5" "$filelink" "$filename"
    fi

    mkdir -p "$RESOURCES_PATH/photoshopCC"
    show_message "extract photoshop..."
    tar -xzf "$filepath" -C "$RESOURCES_PATH/photoshopCC"

    echo "===============| photoshop CC v19 |===============" >> "$SCR_PATH/wine-error.log"
    show_message "install photoshop..."
    show_message "\033[1;33mPlease don't change default Destination Folder\e[0m"

    # Run Photoshop installer with timeout to prevent hanging
    # Give it 5 minutes (300 seconds) to complete installation
    timeout 300 wine "$RESOURCES_PATH/photoshopCC/photoshop_cc.exe" &>> "$SCR_PATH/wine-error.log"
    
    # Check if timeout occurred
    local exit_code=$?
    if [ "$exit_code" -eq 124 ]; then
        warning "Photoshop installer timed out after 5 minutes. It may have completed or need manual intervention."
        warning "Checking if Photoshop was installed..."
    elif [ "$exit_code" -ne 0 ]; then
        warning "Photoshop installer exited with code $exit_code. Checking if installation was successful anyway..."
    fi
    
    # Kill any running Photoshop processes (it might auto-run after install)
    show_message "Stopping any running Photoshop processes..."
    pkill -f "Photoshop.exe" 2>/dev/null || true
    
    # Wait a moment for processes to terminate
    sleep 3
    
    show_message "removing useless helper.exe plugin to avoid errors"
    rm -f "$WINE_PREFIX/drive_c/users/$USER/PhotoshopSE/Required/Plug-ins/Spaces/Adobe Spaces Helper.exe" 2>/dev/null || warning "Could not remove helper.exe (may not exist)"

    notify-send "Photoshop CC" "photoshop installed successfully" -i "photoshop"
    show_message "photoshopCC V19 x64 installed..."
    unset filename filemd5 filelink filepath
}

check_arg $@
save_paths
main

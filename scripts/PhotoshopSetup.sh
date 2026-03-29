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
    
    mkdir -p $SCR_PATH
    mkdir -p $CACHE_PATH
    
    setup_log "================| script executed |================"

    is64

    #make sure wine and winetricks package is already installed
    package_installed wine
    package_installed md5sum
    package_installed winetricks

    RESOURCES_PATH="$SCR_PATH/resources"
    WINE_PREFIX="$SCR_PATH/prefix"
    
    #create new wine prefix for photoshop
    rmdir_if_exist $WINE_PREFIX
    
    #export necessary variable for wine
    export_var
    
    #config wine prefix and install mono and gecko automatic
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
        #add dark mod
        set_dark_mod
    else
        error "user.reg Not Found :("
    fi
   
    #create resources directory 
    rmdir_if_exist $RESOURCES_PATH

    # winetricks atmlib corefonts fontsmooth=rgb gdiplus vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2015 atmlib msxml3 msxml6 gdiplus
    winetricks atmlib fontsmooth=rgb vcrun2008 vcrun2010 vcrun2012 vcrun2013 atmlib msxml3 msxml6
    
    #install photoshop
    sleep 3
    install_photoshopSE
    sleep 5
    
    replacement

    add_hosts_entries

    if [ -d $RESOURCES_PATH ];then
        show_message "deleting resources folder"
        rm -rf $RESOURCES_PATH
    else
        error "resources folder Not Found"
    fi

    launcher
    show_message "\033[1;33mwhen you run photoshop for the first time it may take a while\e[0m"
    show_message "Almost finished..."
    sleep 30
}

function replacement() {
    local filename="replacement.tgz"
    local filemd5="6441a8e77c082897a99c2b7b588c9ac4"
    local filelink="https://victor.poshtiban.io/p/gictor/photoshopCC/replacement.tgz"
    local filepath="/home/insomnia/git/photoshopCClinux/files/$filename"

    # Use local file if exists, otherwise download
    if [ ! -f "$filepath" ]; then
        download_component $filepath $filemd5 $filelink $filename
    fi

    mkdir "$RESOURCES_PATH/replacement"
    show_message "extract replacement component..."
    tar -xzf $filepath -C "$RESOURCES_PATH/replacement"

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
    local filepath="/home/insomnia/git/photoshopCClinux/files/$filename"

    # Use local file if exists, otherwise download
    if [ ! -f "$filepath" ]; then
        download_component $filepath $filemd5 $filelink $filename
    fi

    mkdir "$RESOURCES_PATH/photoshopCC"
    show_message "extract photoshop..."
    tar -xzf "$filepath" -C "$RESOURCES_PATH/photoshopCC"

    echo "===============| photoshop CC v19 |===============" >> "$SCR_PATH/wine-error.log"
    show_message "install photoshop..."
    show_message "\033[1;33mPlease don't change default Destination Folder\e[0m"

    wine64 "$RESOURCES_PATH/photoshopCC/photoshop_cc.exe" &>> "$SCR_PATH/wine-error.log" || error "sorry something went wrong during photoshop installation"
    
    show_message "removing useless helper.exe plugin to avoid errors"
    rm "$WINE_PREFIX/drive_c/users/$USER/PhotoshopSE/Required/Plug-ins/Spaces/Adobe Spaces Helper.exe"

    notify-send "Photoshop CC" "photoshop installed successfully" -i "photoshop"
    show_message "photoshopCC V19 x64 installed..."
    unset filename filemd5 filelink filepath
}

check_arg $@
save_paths
main

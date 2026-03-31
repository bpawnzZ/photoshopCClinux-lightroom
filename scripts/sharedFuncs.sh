
#has tow mode [pkgName] [mode=summary]
function package_installed() {
    which "$1" &> /dev/null
    local pkginstalled="$?"

    if [ "$2" == "summary" ];then
        if [ "$pkginstalled" -eq 0 ];then
            echo "true"
        else
            echo "false"
        fi
    else    
        if [ "$pkginstalled" -eq 0 ];then
            show_message "package\033[1;36m $1\e[0m is installed..."
        else
            warning "package\033[1;33m $1\e[0m is not installed.\nplease make sure it's already installed"
            ask_question "would you continue?" "N"
            if [ "$question_result" == "no" ];then
                echo "exit..."
                exit 5
            fi
        fi
    fi
}

function setup_log() {
    if [ -n "$SCR_PATH" ] && [ -d "$SCR_PATH" ]; then
        echo -e "$(date) : $@" >> "$SCR_PATH/setuplog.log"
    else
        # Fallback to home directory if SCR_PATH not set
        echo -e "$(date) : $@" >> "$HOME/.photoshop-setup.log"
    fi
}

function show_message() {
    echo -e "$@"
    setup_log "$@"
}

function error() {
    echo -e "\033[1;31merror:\e[0m $@"
    setup_log "$@"
    exit 1
}



function warning() {
    echo -e "\033[1;33mWarning:\e[0m $@"
    setup_log "$@"
}

function warning2() {
    echo -e "\033[1;33mWarning:\e[0m $@"
}

function show_message2() {
    echo -e "$@"
}

function launcher() {
    local app_name="${1:-photoshop}"  # Default to photoshop if not specified
    
    # Determine which launcher script to use based on app_name
    local launcher_source=""
    local launcher_dest_name=""
    local launcher_dest="$SCR_PATH/launcher"
    
    case "$app_name" in
        photoshop)
            launcher_source="$PWD/photoshop-launcher.sh"
            launcher_dest_name="photoshop-launcher.sh"
            ;;
        lightroom)
            launcher_source="$PWD/lightroom-launcher.sh"
            launcher_dest_name="lightroom-launcher.sh"
            ;;
        *)
            error "Unknown application: $app_name"
            ;;
    esac
    
    # Only recreate launcher directory if it doesn't exist
    if [ ! -d "$launcher_dest" ]; then
        mkdir -p "$launcher_dest"
        show_message "Created launcher directory: $launcher_dest"
    else
        show_message "Launcher directory already exists: $launcher_dest"
    fi

    if [ -f "$launcher_source" ];then
        show_message "$launcher_dest_name detected..."
        
        # Only copy launcher if it doesn't exist or is different
        if [ ! -f "$launcher_dest/$launcher_dest_name" ] || ! cmp -s "$launcher_source" "$launcher_dest/$launcher_dest_name"; then
            cp "$launcher_source" "$launcher_dest" || error "can't copy launcher"
            sed -i "s|pspath|$SCR_PATH|g" "$launcher_dest/$launcher_dest_name" && sed -i "s|pscache|$CACHE_PATH|g" "$launcher_dest/$launcher_dest_name" || error "can't edit launcher script"
            chmod +x "$launcher_dest/$launcher_dest_name" || error "can't chmod launcher script"
            show_message "Launcher script updated: $launcher_dest_name"
        else
            show_message "Launcher script already up to date: $launcher_dest_name"
        fi
    else
        error "Launcher script not found: $launcher_source"
    fi

    # Determine which desktop entry to create based on app_name
    local desktop_entry=""
    local desktop_entry_dest=""
    local icon_source=""
    local icon_dest=""
    local command_name=""
    
    case "$app_name" in
        photoshop)
            desktop_entry="$PWD/photoshop.desktop"
            desktop_entry_dest="/home/$USER/.local/share/applications/photoshop.desktop"
            icon_source="../images/AdobePhotoshop-icon.png"
            icon_dest="$launcher_dest/AdobePhotoshop-icon.png"
            command_name="photoshop"
            ;;
        lightroom)
            desktop_entry="$PWD/lightroom.desktop"
            desktop_entry_dest="/home/$USER/.local/share/applications/lightroom.desktop"
            icon_source="../images/lightroom.png"
            icon_dest="$launcher_dest/lightroom.png"
            command_name="lightroom"
            ;;
        *)
            error "Unknown application: $app_name"
            ;;
    esac
    
    # Create desktop entry
    if [ -f "$desktop_entry" ];then
        show_message "Creating desktop entry for $app_name..."
       
        # Backup existing desktop entry if it exists
        if [ -f "$desktop_entry_dest" ];then
            show_message "Backing up existing desktop entry..."
            mv "$desktop_entry_dest" "${desktop_entry_dest}.backup" 2>/dev/null || warning "Could not backup desktop entry"
        fi
        
        cp "$desktop_entry" "$desktop_entry_dest" || error "can't copy desktop entry"
        sed -i "s|pspath|$SCR_PATH|g" "$desktop_entry_dest" || error "can't edit desktop entry"
        show_message "Desktop entry created: $desktop_entry_dest"
    else
        error "Desktop entry not found: $desktop_entry"
    fi

    # Copy icon
    if [ -f "$icon_source" ]; then
        cp "$icon_source" "$icon_dest" || error "can't copy icon image"
        show_message "Icon copied: $icon_dest"
        
        # Update desktop entry with correct icon path
        sed -i "s|photoshopicon|$icon_dest|g" "$desktop_entry_dest" || warning "Could not update icon path in desktop entry"
    else
        warning "Icon not found: $icon_source"
    fi

    # Create application command (symlink directly to launcher)
    show_message "Creating $app_name command..."
    
    # Determine which launcher to symlink to
    local launcher_target=""
    case "$app_name" in
        photoshop)
            launcher_target="$SCR_PATH/launcher/photoshop-launcher.sh"
            ;;
        lightroom)
            launcher_target="$SCR_PATH/launcher/lightroom-launcher.sh"
            ;;
    esac
    
    if [ -f "/usr/local/bin/$command_name" ];then
        show_message "$command_name command already exists, updating..."
        sudo rm "/usr/local/bin/$command_name" 2>/dev/null || warning "Could not remove existing command (no sudo access?)"
    fi
    
    sudo mkdir -p "/usr/local/bin" 2>/dev/null || warning "Could not create /usr/local/bin directory (no sudo access?)"
    
    if sudo ln -s "$launcher_target" "/usr/local/bin/$command_name" 2>/dev/null; then
        show_message "Command created: /usr/local/bin/$command_name -> $launcher_target"
    else
        # Try user-local command
        show_message "Could not create system command (no sudo access). Trying user-local command..."
        mkdir -p "$HOME/.local/bin"
        if ln -sf "$launcher_target" "$HOME/.local/bin/$command_name" 2>/dev/null; then
            export PATH="$HOME/.local/bin:$PATH"
            show_message "User command created: $HOME/.local/bin/$command_name -> $launcher_target"
            show_message "Added $HOME/.local/bin to PATH for this session"
        else
            warning "Failed to create $command_name command. You can run the application from the desktop entry."
        fi
    fi

    unset desktop_entry desktop_entry_dest launcher_source launcher_dest_name launcher_dest icon_source icon_dest command_name launcher_target
}

function set_dark_mod() {
    echo " " >> "$WINE_PREFIX/user.reg"
    local colorarray=(
        '[Control Panel\\Colors] 1491939580'
        '#time=1d2b2fb5c69191c'
        '"ActiveBorder"="49 54 58"'
        '"ActiveTitle"="49 54 58"'
        '"AppWorkSpace"="60 64 72"'
        '"Background"="49 54 58"'
        '"ButtonAlternativeFace"="200 0 0"'
        '"ButtonDkShadow"="154 154 154"'
        '"ButtonFace"="49 54 58"'
        '"ButtonHilight"="119 126 140"'
        '"ButtonLight"="60 64 72"'
        '"ButtonShadow"="60 64 72"'
        '"ButtonText"="219 220 222"'
        '"GradientActiveTitle"="49 54 58"'
        '"GradientInactiveTitle"="49 54 58"'
        '"GrayText"="155 155 155"'
        '"Hilight"="119 126 140"'
        '"HilightText"="255 255 255"'
        '"InactiveBorder"="49 54 58"'
        '"InactiveTitle"="49 54 58"'
        '"InactiveTitleText"="219 220 222"'
        '"InfoText"="159 167 180"'
        '"InfoWindow"="49 54 58"'
        '"Menu"="49 54 58"'
        '"MenuBar"="49 54 58"'
        '"MenuHilight"="119 126 140"'
        '"MenuText"="219 220 222"'
        '"Scrollbar"="73 78 88"'
        '"TitleText"="219 220 222"'
        '"Window"="35 38 41"'
        '"WindowFrame"="49 54 58"'
        '"WindowText"="219 220 222"'
    )
    for i in "${colorarray[@]}";do
        echo "$i" >> "$WINE_PREFIX/user.reg"
    done
    show_message "set dark mode for wine..." 
    unset colorarray
}

function export_var() {
    export WINEPREFIX="$WINE_PREFIX"
    export WINEARCH=win64
    show_message "wine variables exported..."
}

#parameters is [PATH] [CheckSum] [URL] [FILE NAME]
function download_component() {
    local tout=0
    while true;do
        if [ "$tout" -ge 3 ];then
            error "Failed to download $4 after 3 attempts.

Possible solutions:
1. Check your internet connection
2. Try again later - the download server might be temporarily unavailable
3. Download manually from: $3
   and place it in: $CACHE_PATH/
4. If you have the file elsewhere, copy it to: $CACHE_PATH/$4

Error details logged to: $SCR_PATH/setuplog.log"
        fi
        if [ -f "$1" ];then
            local FILE_ID=$(md5sum "$1" | cut -d" " -f1)
            if [ "$FILE_ID" == $2 ];then
                show_message "\033[1;36m$4\e[0m detected"
                return 0
            else
                show_message "md5 is not match"
                rm "$1" 
            fi
        else   
            show_message "downloading $4 ..."
            ariapkg=$(package_installed aria2c "summary")
            curlpkg=$(package_installed curl "summary")
            
            ((tout++))
            if [ "$ariapkg" == "true" ];then
                show_message "using aria2c to download $4"
                if ! aria2c -c -x 8 -d "$CACHE_PATH" -o "$4" "$3"; then
                    warning "aria2c download failed for $4"
                    continue
                fi
                
                notify-send "Photoshop CC" "$4 download completed" -i "download"

            elif [ "$curlpkg" == "true" ];then
                show_message "using curl to download $4"
                if ! curl -f -L "$3" -o "$1"; then
                    warning "curl download failed for $4 (URL: $3)"
                    continue
                fi
            else
                show_message "using wget to download $4"
                if ! wget --no-check-certificate "$3" -P "$CACHE_PATH"; then
                    warning "wget download failed for $4 (URL: $3)"
                    continue
                fi
                
                notify-send "Photoshop CC" "$4 download completed" -i "download"
            fi
        fi
    done
}

function rmdir_if_exist() {
    if [ -d "$1" ];then
        warning "WARNING: Directory $1 already exists and will be DELETED: rm -rf $1"
        warning "This will permanently delete all contents of $1"
        ask_question "Continue with deletion?" "N"
        if [ "$question_result" == "no" ]; then
            error "Operation cancelled by user."
        fi
        rm -rf "$1"
        show_message "\033[0;36m$1\e[0m directory exists deleting it..."
    fi
    mkdir -p "$1"
    show_message "create\033[0;36m $1\e[0m directory..."
}

function check_arg() {
    while getopts "hd:c:" OPTION; do
        case $OPTION in
        d)
            PARAMd="$OPTARG"
            SCR_PATH=$(readlink -f "$PARAMd")
            
            dashd=1
            echo "install path is $SCR_PATH"
            ;;
        c)
            PARAMc="$OPTARG"
            CACHE_PATH=$(readlink -f "$PARAMc")
            dashc=1
            echo "cahce is $CACHE_PATH"
            ;;
        h)
            usage
            ;; 
        *)
            echo "wrong argument"
            exit 1
            ;;
        esac
    done
    shift $(($OPTIND - 1))

    if [[ $# != 0 ]];then
        usage
        error "unknown argument"
    fi

    if [[ $dashd != 1 ]] ;then
        echo "-d not define default directory used..."
        SCR_PATH="$HOME/.photoshopCCV19"
    fi

    if [[ $dashc != 1 ]];then
        echo "-c not define default directory used..."
        CACHE_PATH="$HOME/.cache/photoshopCCV19"
    fi
}

function is64() {
    local arch=$(uname -m)
    if [ "$arch" != "x86_64"  ];then
        warning "your distro is not 64 bit"
        read -r -p "Would you continue? [N/y] " response
        if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]];then
           echo "Good Bye!"
           exit 0
        fi
    fi
   show_message "is64 checked..."
}

#parameters [Message] [default flag [Y/N]]
function ask_question() {
    question_result=""
    if [ "$2" == "Y" ];then
        read -r -p "$1 [Y/n] " response
        if [[ "$response" =~ $(locale noexpr) ]];then
            question_result="no"
        else
            question_result="yes"
        fi
    elif [ "$2" == "N" ];then
        read -r -p "$1 [N/y] " response
        if [[ "$response" =~ $(locale yesexpr) ]];then
            question_result="yes"
        else
            question_result="no"
        fi
    fi
}

function usage() {
    echo "USAGE: [-c cache directory] [-d installation directory]"
}

# Check if user has sudo permissions, provide helpful message if not
function check_sudo_access() {
    if [ "$EUID" -eq 0 ]; then
        return 0  # Already root
    fi
    
    if sudo -n true 2>/dev/null; then
        return 0  # Has sudo access without password
    fi
    
    # Try to run a simple sudo command
    if ! sudo -v 2>/dev/null; then
        warning "You don't have sudo access or need to enter password."
        warning "Some operations may fail. You can:"
        warning "1. Run with sudo: sudo $0"
        warning "2. Contact your system administrator"
        warning "3. Some features will use user-local fallbacks"
        return 1
    fi
    return 0
}

# Safe sudo wrapper that provides better error messages
function safe_sudo() {
    if [ "$EUID" -eq 0 ]; then
        # Already root, run command directly
        "$@"
    elif check_sudo_access; then
        sudo "$@"
    else
        warning "Cannot run '$*' with sudo. Trying alternative approach..."
        return 1
    fi
}

function save_paths() {
    local datafile="$HOME/.psdata.txt"
    echo "$SCR_PATH" > "$datafile"
    echo "$CACHE_PATH" >> "$datafile"
    unset datafile
}

function load_paths() {
    local datafile="$HOME/.psdata.txt"
    SCR_PATH=$(head -n 1 "$datafile")
    CACHE_PATH=$(tail -n 1 "$datafile")
    unset datafile
}

# Detect Linux distribution and package manager
function detect_distro() {
    local distro_id=""
    local pkg_manager=""
    
    # Check for /etc/os-release first
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        distro_id="$ID"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        distro_id="$DISTRIB_ID"
    elif [ -f /etc/debian_version ]; then
        distro_id="debian"
    elif [ -f /etc/fedora-release ]; then
        distro_id="fedora"
    elif [ -f /etc/redhat-release ]; then
        distro_id="rhel"
    elif [ -f /etc/arch-release ]; then
        distro_id="arch"
    else
        distro_id="unknown"
    fi
    
    # Convert to lowercase for consistency
    distro_id=$(echo "$distro_id" | tr '[:upper:]' '[:lower:]')
    
    # Determine package manager based on distro
    case "$distro_id" in
        arch|manjaro|endeavouros)
            pkg_manager="pacman"
            ;;
        debian|ubuntu|linuxmint|pop|elementary|zorin|deepin|kali|parrot)
            pkg_manager="apt"
            ;;
        fedora|rhel|centos|almalinux|rocky|ol)
            if command -v dnf >/dev/null 2>&1; then
                pkg_manager="dnf"
            else
                pkg_manager="yum"
            fi
            ;;
        opensuse*|suse|sled)
            pkg_manager="zypper"
            ;;
        gentoo)
            pkg_manager="emerge"
            ;;
        void)
            pkg_manager="xbps"
            ;;
        alpine)
            pkg_manager="apk"
            ;;
        *)
            pkg_manager="unknown"
            ;;
    esac
    
    # Return values
    DISTRO_ID="$distro_id"
    PKG_MANAGER="$pkg_manager"
    
    show_message "Detected distribution: $distro_id, Package manager: $pkg_manager"
}

# Check if a package is installed (supports multiple package managers)
function check_package() {
    local pkg_name="$1"
    local is_installed=false
    
    case "$PKG_MANAGER" in
        pacman)
            pacman -Qi "$pkg_name" >/dev/null 2>&1 && is_installed=true
            ;;
        apt)
            dpkg -l "$pkg_name" 2>/dev/null | grep -q "^ii" && is_installed=true
            ;;
        dnf|yum)
            rpm -q "$pkg_name" >/dev/null 2>&1 && is_installed=true
            ;;
        zypper)
            rpm -q "$pkg_name" >/dev/null 2>&1 && is_installed=true
            ;;
        emerge)
            qlist -I "$pkg_name" >/dev/null 2>&1 && is_installed=true
            ;;
        xbps)
            xbps-query "$pkg_name" >/dev/null 2>&1 && is_installed=true
            ;;
        apk)
            apk info -e "$pkg_name" >/dev/null 2>&1 && is_installed=true
            ;;
        *)
            # Fallback to which command
            which "$pkg_name" >/dev/null 2>&1 && is_installed=true
            ;;
    esac
    
    echo "$is_installed"
}

# Install packages based on detected package manager
function install_packages() {
    local packages=("$@")
    local install_cmd=""
    local sudo_cmd="sudo"
    
    # Check if we're already root
    if [ "$EUID" -eq 0 ]; then
        sudo_cmd=""
    fi
    
    case "$PKG_MANAGER" in
        pacman)
            install_cmd="$sudo_cmd pacman -S --needed --noconfirm"
            ;;
        apt)
            install_cmd="$sudo_cmd apt-get install -y"
            # Update package list first
            $sudo_cmd apt-get update
            ;;
        dnf)
            install_cmd="$sudo_cmd dnf install -y"
            ;;
        yum)
            install_cmd="$sudo_cmd yum install -y"
            ;;
        zypper)
            install_cmd="$sudo_cmd zypper install -y"
            ;;
        emerge)
            install_cmd="$sudo_cmd emerge -av"
            ;;
        xbps)
            install_cmd="$sudo_cmd xbps-install -S"
            ;;
        apk)
            install_cmd="$sudo_cmd apk add"
            ;;
        *)
            warning "Unknown package manager: $PKG_MANAGER"
            return 1
            ;;
    esac
    
    show_message "Installing packages: ${packages[*]}"
    
    # Install packages
    if ! $install_cmd "${packages[@]}"; then
        warning "Failed to install some packages. Trying to continue..."
        return 1
    fi
    
    return 0
}

# Get Wine dependency packages based on distribution
function get_wine_dependencies() {
    local deps=()
    
    case "$DISTRO_ID" in
        arch|manjaro|endeavouros)
            # Arch Linux dependencies from README
            deps=(
                wine-staging
                winetricks
                giflib lib32-giflib
                libpng lib32-libpng
                libldap lib32-libldap
                gnutls lib32-gnutls
                mpg123 lib32-mpg123
                openal lib32-openal
                v4l-utils lib32-v4l-utils
                libpulse lib32-libpulse
                alsa-plugins lib32-alsa-plugins
                alsa-lib lib32-alsa-lib
                libjpeg-turbo lib32-libjpeg-turbo
                libxcomposite lib32-libxcomposite
                libxinerama lib32-libxinerama
                ncurses lib32-ncurses
                opencl-icd-loader lib32-opencl-icd-loader
                libxslt lib32-libxslt
                libva lib32-libva
                gtk3 lib32-gtk3
                gst-plugins-base-libs lib32-gst-plugins-base-libs
                vulkan-icd-loader lib32-vulkan-icd-loader
                cups
                samba
                dosbox
            )
            ;;
        debian|ubuntu|linuxmint|pop|elementary|zorin|deepin|kali|parrot)
            # Debian/Ubuntu dependencies
            deps=(
                winehq-staging
                winetricks
            )
            # Note: For Debian/Ubuntu, 32-bit architecture needs to be enabled first
            # This is handled separately
            ;;
        fedora|rhel|centos|almalinux|rocky|ol)
            # Fedora/RHEL dependencies
            deps=(
                wine
                winetricks
            )
            ;;
        *)
            # Generic fallback - minimal Wine installation
            deps=(wine winetricks)
            warning "Unknown distribution $DISTRO_ID, installing generic Wine packages"
            ;;
    esac
    
    echo "${deps[@]}"
}

# Check and install Wine with all dependencies
function check_install_wine() {
    show_message "Checking Wine installation..."
    
    # First detect distribution
    detect_distro
    
    # Check if wine is installed
    if [ "$(check_package wine)" = "false" ] && [ "$(check_package wine-staging)" = "false" ] && [ "$(check_package winehq-staging)" = "false" ]; then
        warning "Wine is not installed. Installing Wine and dependencies..."
        
        # Get dependencies for this distribution
        local wine_deps=($(get_wine_dependencies))
        
        # Special handling for Debian/Ubuntu
        if [[ "$DISTRO_ID" =~ ^(debian|ubuntu|linuxmint|pop|elementary|zorin|deepin|kali|parrot)$ ]]; then
            show_message "Setting up WineHQ repository for Debian/Ubuntu based systems..."
            
            # Check if 32-bit architecture is enabled
            if ! dpkg --print-foreign-architectures | grep -q i386; then
                show_message "Enabling 32-bit architecture..."
                sudo dpkg --add-architecture i386
            fi
            
            # Add WineHQ repository key
            if [ ! -f /usr/share/keyrings/winehq-archive.key ]; then
                show_message "Adding WineHQ repository key..."
                sudo mkdir -p /usr/share/keyrings
                wget -q -O- https://dl.winehq.org/wine-builds/winehq.key | sudo tee /usr/share/keyrings/winehq-archive.key >/dev/null
            fi
            
            # Add repository based on Ubuntu version
            local ubuntu_codename=""
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                ubuntu_codename="$VERSION_CODENAME"
            fi
            
            if [ -n "$ubuntu_codename" ]; then
                show_message "Adding WineHQ repository for $ubuntu_codename..."
                if check_sudo_access; then
                    echo "deb [signed-by=/usr/share/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ $ubuntu_codename main" | sudo tee /etc/apt/sources.list.d/winehq.list
                    sudo apt-get update
                else
                    warning "Cannot add WineHQ repository without sudo access."
                    warning "You may need to install Wine manually or run with sudo."
                fi
            fi
        fi
        
        # Install Wine and dependencies
        install_packages "${wine_deps[@]}"
        
        if [ $? -eq 0 ]; then
            show_message "Wine installation completed successfully."
        else
            warning "Wine installation encountered issues. Photoshop may not work correctly."
        fi
    else
        show_message "Wine is already installed."
    fi
    
    # Check for wine64 and create symlink if needed
    check_wine_symlink
}

# Enhanced wine symlink checking with priority: wine-staging > wine64 > wine
function check_wine_symlink() {
    show_message "Checking wine/wine64/wine-staging symlinks..."
    
    # Priority order: wine-staging > wine64 > wine
    local wine_priority=("wine-staging" "wine64" "wine")
    local found_wine=""
    local found_path=""
    
    # Check for available wine variants in priority order
    for wine_variant in "${wine_priority[@]}"; do
        if command -v "$wine_variant" >/dev/null 2>&1; then
            found_wine="$wine_variant"
            found_path="$(command -v "$wine_variant")"
            show_message "Found $found_wine at: $found_path"
            break
        fi
    done
    
    # No wine variant found
    if [ -z "$found_wine" ]; then
        error "No wine variant found (checked: wine-staging, wine64, wine). Wine installation may have failed."
        return 1
    fi
    
    # Check if 'wine' command already exists and points to the found variant
    if command -v wine >/dev/null 2>&1; then
        local current_wine_path="$(command -v wine)"

        # Check if it's already a symlink to our found variant
        if [ -L "$current_wine_path" ] && [ "$(readlink -f "$current_wine_path")" = "$found_path" ]; then
            show_message "wine is already symlinked to $found_wine ($found_path)"
            return 0
        fi

        # Check if it's already the correct binary (not a symlink)
        if [ "$current_wine_path" = "$found_path" ] && [ -f "$current_wine_path" ] && [ ! -L "$current_wine_path" ]; then
            show_message "wine is already the correct binary ($found_path)"
            return 0
        fi
        
        # wine exists but doesn't point to our found variant
        show_message "wine exists at $current_wine_path but doesn't point to $found_wine"
        
        # Check if this is a circular symlink (wine -> wine64 -> wine)
        if [ -L "$current_wine_path" ]; then
            local link_target="$(readlink "$current_wine_path")"
            if [ "$link_target" = "wine64" ] || [ "$link_target" = "wine" ]; then
                show_message "Detected circular symlink: $current_wine_path -> $link_target"
                show_message "Removing broken symlink..."
                safe_sudo rm "$current_wine_path" 2>/dev/null || warning "Could not remove symlink (no sudo access?)"
            fi
        fi
        
        # Backup original if it's a regular file (not a symlink)
        if [ -f "$current_wine_path" ] && [ ! -L "$current_wine_path" ]; then
            show_message "Backing up original wine binary..."
            safe_sudo mv "$current_wine_path" "${current_wine_path}.backup" 2>/dev/null || warning "Could not backup wine binary (no sudo access?)"
        fi
        
        # Create symlink to found variant
        show_message "Creating wine -> $found_wine symlink..."
        if safe_sudo ln -sf "$found_path" "$current_wine_path" 2>/dev/null; then
            show_message "Symlink created: $current_wine_path -> $found_path"
        else
            # Try user-local symlink
            show_message "Could not create system symlink (no sudo access). Trying user-local symlink..."
            mkdir -p "$HOME/.local/bin"
            if ln -sf "$found_path" "$HOME/.local/bin/wine" 2>/dev/null; then
                export PATH="$HOME/.local/bin:$PATH"
                show_message "User symlink created: $HOME/.local/bin/wine -> $found_path"
                show_message "Added $HOME/.local/bin to PATH for this session"
            else
                warning "Failed to create wine symlink. Photoshop may not work correctly."
                return 1
            fi
        fi
    else
        # wine command doesn't exist - create it
        show_message "wine command not found. Creating symlink to $found_wine..."
        
        # Try system-wide symlink first
        if safe_sudo ln -sf "$found_path" /usr/bin/wine 2>/dev/null; then
            show_message "System symlink created: /usr/bin/wine -> $found_path"
        else
            # Try user-local symlink
            show_message "Could not create system symlink (no sudo access). Trying user-local symlink..."
            mkdir -p "$HOME/.local/bin"
            if ln -sf "$found_path" "$HOME/.local/bin/wine" 2>/dev/null; then
                export PATH="$HOME/.local/bin:$PATH"
                show_message "User symlink created: $HOME/.local/bin/wine -> $found_path"
                show_message "Added $HOME/.local/bin to PATH for this session"
            else
                warning "Failed to create wine symlink. Photoshop may not work correctly."
                return 1
            fi
        fi
    fi
    
    # Verify the symlink works
    if ! wine --version >/dev/null 2>&1; then
        warning "wine command test failed. There may be issues with the Wine installation."
        warning "If you created a user-local symlink, make sure $HOME/.local/bin is in your PATH"
        return 1
    else
        show_message "Wine version: $(wine --version 2>/dev/null | head -n1 || echo 'Unknown')"
        show_message "Wine architecture: $(wine wineboot --version 2>/dev/null | grep -i 'wine' || echo 'Unknown')"
    fi
    
    
    case "$DISTRO_ID" in
        arch|manjaro|endeavouros)
            # Arch should have multilib enabled by default
            if ! pacman -Sl multilib >/dev/null 2>&1; then
                warning "Multilib repository may not be enabled on Arch Linux."
                warning "Please enable multilib in /etc/pacman.conf for 32-bit library support."
            fi
            ;;
        debian|ubuntu|linuxmint|pop|elementary|zorin|deepin|kali|parrot)
            # Already handled in check_install_wine
            ;;
        fedora|rhel|centos|almalinux|rocky|ol)
            # Check for 32-bit support
            if ! dnf repoquery --available --whatprovides '*.i686' >/dev/null 2>&1; then
                warning "32-bit repository may not be enabled. Some Wine dependencies may be missing."
            fi
             ;;
     esac
}

# ==================== INTELLIGENT DEPENDENCY MANAGEMENT ====================

# Check if Wine prefix exists and is valid
function check_wine_prefix() {
    if [ -d "$WINE_PREFIX" ] && [ -f "$WINE_PREFIX/system.reg" ]; then
        echo "true"
    else
        echo "false"
    fi
}

# Check if specific winetricks component is installed
function check_winetricks_component() {
    local component="$1"
    
    if [ ! -d "$WINE_PREFIX" ]; then
        echo "false"
        return
    fi
    
    # Check registry for component installation
    if grep -qi "$component" "$WINE_PREFIX/system.reg" 2>/dev/null || \
       grep -qi "$component" "$WINE_PREFIX/user.reg" 2>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
}

# Get list of Adobe application dependencies
function get_adobe_dependencies() {
    # Common dependencies for Photoshop and Lightroom
    echo "atmlib fontsmooth=rgb vcrun2008 vcrun2010 vcrun2012 vcrun2013 msxml3 msxml6"
}

# Install only missing dependencies
function install_missing_dependencies() {
    local app_name="$1"
    
    show_message "Checking dependencies for $app_name..."
    
    # Check if Wine prefix exists
    if [ "$(check_wine_prefix)" = "false" ]; then
        show_message "Creating new Wine prefix..."
        winecfg 2> "$SCR_PATH/wine-error.log" || error "Failed to create Wine prefix"
        
        if [ -f "$WINE_PREFIX/user.reg" ]; then
            set_dark_mod
        fi
        
        # Install all dependencies for fresh prefix
        show_message "Installing all Windows dependencies..."
        winetricks $(get_adobe_dependencies)
        return 0
    fi
    
    # Wine prefix exists, check what's missing
    show_message "Wine prefix already exists, checking for missing dependencies..."
    
    local missing_deps=()
    local all_deps=($(get_adobe_dependencies))
    
    for dep in "${all_deps[@]}"; do
        if [ "$(check_winetricks_component "$dep")" = "false" ]; then
            missing_deps+=("$dep")
            show_message "Missing: $dep"
        else
            show_message "Already installed: $dep"
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        show_message "Installing missing dependencies: ${missing_deps[*]}"
        winetricks "${missing_deps[@]}"
    else
        show_message "All dependencies are already installed!"
    fi
}

# Safe directory creation (doesn't delete if exists)
function safe_create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        show_message "Created directory: $1"
    else
        show_message "Directory already exists: $1"
    fi
}

# Check if Adobe application is already installed
function check_adobe_app_installed() {
    local app_name="$1"
    
    case "$app_name" in
        photoshop)
            if [ -f "$WINE_PREFIX/drive_c/users/$USER/PhotoshopSE/Photoshop.exe" ]; then
                echo "true"
            else
                echo "false"
            fi
            ;;
        lightroom)
            if [ -f "$WINE_PREFIX/drive_c/users/$USER/LightroomSE/Lightroom.8/LightroomPortable.exe" ] || \
               [ -f "$RESOURCES_PATH/lightroomCC/LightroomSE/Lightroom.8/LightroomPortable.exe" ]; then
                echo "true"
            else
                echo "false"
            fi
            ;;
        *)
            echo "false"
            ;;
    esac
}

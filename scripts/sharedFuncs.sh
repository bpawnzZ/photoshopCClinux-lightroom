
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

function error2() {
    echo -e "\033[1;31merror:\e[0m $@"
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
    
    #create launcher script
    local launcher_path="$PWD/launcher.sh"
    local launcher_dest="$SCR_PATH/launcher"
    rmdir_if_exist "$launcher_dest"


    if [ -f "$launcher_path" ];then
        show_message "launcher.sh detected..."
        
        cp "$launcher_path" "$launcher_dest" || error "can't copy launcher"
        
        sed -i "s|pspath|$SCR_PATH|g" "$launcher_dest/launcher.sh" && sed -i "s|pscache|$CACHE_PATH|g" "$launcher_dest/launcher.sh" || error "can't edit launcher script"
        
        chmod +x "$SCR_PATH/launcher/launcher.sh" || error "can't chmod launcher script"
    else
        error "launcher.sh Note Found"
    fi

    #create desktop entry
    local desktop_entry="$PWD/photoshop.desktop"
    local desktop_entry_dest="/home/$USER/.local/share/applications/photoshop.desktop"
    
    if [ -f "$desktop_entry" ];then
        show_message "desktop entry detected..."
       
        #delete desktop entry if exists
        if [ -f "$desktop_entry_dest" ];then
            show_message "desktop entry exist deleted..."
            rm "$desktop_entry_dest"
        fi
        cp "$desktop_entry" "$desktop_entry_dest" || error "can't copy desktop entry"
        sed -i "s|pspath|$SCR_PATH|g" "$desktop_entry_dest" || error "can't edit desktop entry"
    else
        error "desktop entry Not Found"
    fi

    #change photoshop icon of desktop entry
    local entry_icon="../images/AdobePhotoshop-icon.png"
    local launch_icon="$launcher_dest/AdobePhotoshop-icon.png"

    cp "$entry_icon" "$launcher_dest" || error "can't copy icon image"
    sed -i "s|photoshopicon|$launch_icon|g" "$desktop_entry_dest" || error "can't edit desktop entry"
    sed -i "s|photoshopicon|$launch_icon|g" "$launcher_dest/launcher.sh" || error "can't edit launcher script"
    
    #create photoshop command
    show_message "create photoshop command..."
    if [ -f "/usr/local/bin/photoshop" ];then
        show_message "photoshop command exist deleted..."
        sudo rm "/usr/local/bin/photoshop"
    fi
    sudo mkdir -p "/usr/local/bin"
    sudo ln -s "$SCR_PATH/launcher/launcher.sh" "/usr/local/bin/photoshop" || error "can't create photoshop command"

    unset desktop_entry desktop_entry_dest launcher_path launcher_dest
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
        if [ $tout -ge 3 ];then
            error "sorry something went wrong during download $4"
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
            
            if [ "$ariapkg" == "true" ];then
                show_message "using aria2c to download $4"
                aria2c -c -x 8 -d "$CACHE_PATH" -o "$4" "$3"
                
                if [ $? -eq 0 ];then
                    notify-send "Photoshop CC" "$4 download completed" -i "download"
                fi

            elif [ "$curlpkg" == "true" ];then
                show_message "using curl to download $4"
                curl "$3" -o "$1"
            else
                show_message "using wget to download $4"
                wget --no-check-certificate "$3" -P "$CACHE_PATH"
                
                if [ $? -eq 0 ];then
                    notify-send "Photoshop CC" "$4 download completed" -i "download"
                fi
            fi
            ((tout++))
        fi
    done
}

function rmdir_if_exist() {
    if [ -d "$1" ];then
        rm -rf "$1"
        show_message "\033[0;36m$1\e[0m directory exists deleting it..."
    fi
    mkdir "$1"
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
        error2 "unknown argument"
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
                echo "deb [signed-by=/usr/share/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ $ubuntu_codename main" | sudo tee /etc/apt/sources.list.d/winehq.list
                sudo apt-get update
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

# Enhanced wine symlink checking
function check_wine_symlink() {
    show_message "Checking wine/wine64 symlink..."
    
    # Check if wine command exists
    if command -v wine >/dev/null 2>&1; then
        show_message "wine command found: $(command -v wine)"
        
        # Check if it's a symlink to wine64
        if [ -L "$(command -v wine)" ] && [ "$(readlink -f "$(command -v wine)")" = "$(command -v wine64 2>/dev/null || echo '')" ]; then
            show_message "wine is already symlinked to wine64."
        elif command -v wine64 >/dev/null 2>&1; then
            # Create symlink if wine64 exists but wine doesn't point to it
            show_message "Creating wine -> wine64 symlink..."
            local wine_path="$(command -v wine)"
            local wine64_path="$(command -v wine64)"
            
            # Backup original wine if it exists and isn't already wine64
            if [ -f "$wine_path" ] && [ ! -L "$wine_path" ]; then
                show_message "Backing up original wine binary..."
                sudo mv "$wine_path" "${wine_path}.backup"
            fi
            
            # Create symlink
            sudo ln -sf "$wine64_path" "$wine_path"
            show_message "Symlink created: $wine_path -> $wine64_path"
        fi
    elif command -v wine64 >/dev/null 2>&1; then
        # wine64 exists but wine doesn't - create symlink
        show_message "wine64 found but wine not found. Creating symlink..."
        local wine64_path="$(command -v wine64)"
        sudo ln -sf "$wine64_path" /usr/bin/wine
        show_message "Symlink created: /usr/bin/wine -> $wine64_path"
    else
        error "Neither wine nor wine64 found. Wine installation may have failed."
    fi
    
    # Verify the symlink works
    if ! wine --version >/dev/null 2>&1; then
        warning "wine command test failed. There may be issues with the Wine installation."
    else
        show_message "Wine version: $(wine --version 2>/dev/null | head -n1 || echo 'Unknown')"
    fi
}

# Check for 32-bit library support
function check_32bit_support() {
    show_message "Checking 32-bit library support..."
    
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

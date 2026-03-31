#!/usr/bin/env bash

# Source shared functions
if [ -f "scripts/sharedFuncs.sh" ]; then
    source "scripts/sharedFuncs.sh"
else
    echo "Error: scripts/sharedFuncs.sh not found!"
    exit 1
fi

# ==================== DISTRO DETECTION ====================
# Uses detect_distro() from sharedFuncs.sh which sets DISTRO_ID and PKG_MANAGER

# ==================== DEPENDENCY CHECKING ====================
function check_wine_installation() {
    echo "Checking Wine installation..."
    
    # Check for any wine binary
    if command -v wine &> /dev/null || command -v wine64 &> /dev/null || command -v wine-staging &> /dev/null; then
        echo "✓ Wine is installed"
        return 0
    fi
    
    # Use distro detection from sharedFuncs.sh
    detect_distro  # This sets DISTRO_ID and PKG_MANAGER in sharedFuncs.sh
    local distro="$DISTRO_ID"
    local pm="$PKG_MANAGER"
    
    echo -e "\033[1;33mWine not found!\e[0m"
    echo "This setup requires Wine to run Photoshop CC."
    echo ""
    echo "To install Wine, run one of these commands based on your distribution:"
    echo ""
    
    case "$pm" in
        pacman)
            echo "  Arch/Manjaro:"
            echo "    sudo pacman -S wine-staging winetricks"
            echo "    # For full dependencies, see README.md"
            ;;
        apt)
            echo "  Ubuntu/Debian:"
            echo "    sudo dpkg --add-architecture i386"
            echo "    sudo apt update"
            echo "    sudo apt install --install-recommends winehq-staging winetricks"
            ;;
        dnf|yum)
            echo "  Fedora/RHEL/CentOS:"
            echo "    sudo dnf install wine winetricks"
            ;;
        zypper)
            echo "  openSUSE:"
            echo "    sudo zypper install wine winetricks"
            ;;
        *)
            echo "  Unknown distribution. Please install Wine and winetricks manually."
            echo "  Visit: https://wiki.winehq.org/Download"
            ;;
    esac
    
    echo ""
    echo "After installing Wine, run this setup again."
    return 1
}

function check_required_tools() {
    local missing=()
    
    # Check for winetricks
    if ! command -v winetricks &> /dev/null; then
        missing+=("winetricks")
    fi
    
    # Check for at least one download tool
    if ! command -v aria2c &> /dev/null && \
       ! command -v curl &> /dev/null && \
       ! command -v wget &> /dev/null; then
        missing+=("aria2c, curl, or wget")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "\033[1;33mMissing tools: ${missing[*]}\e[0m"
        echo "Some features may not work properly."
        echo "Consider installing missing tools for better experience."
        return 1
    fi
    
    echo "✓ All required tools are available"
    return 0
}

function check_wine_dependencies() {
    detect_distro  # This sets DISTRO_ID and PKG_MANAGER in sharedFuncs.sh
    local pm="$PKG_MANAGER"
    local missing_deps=()
    
    # Only check for Arch Linux (most detailed dependency list in README)
    if [ "$pm" = "pacman" ]; then
        echo "Checking recommended Wine dependencies for Arch Linux..."
        
        # Check some critical dependencies from README
        local critical_deps=(
            "lib32-giflib" "lib32-libpng" "lib32-libldap" "lib32-gnutls"
            "lib32-mpg123" "lib32-openal" "lib32-v4l-utils" "lib32-libpulse"
            "lib32-alsa-plugins" "lib32-alsa-lib" "lib32-libjpeg-turbo"
        )
        
        for dep in "${critical_deps[@]}"; do
            if ! pacman -Q "$dep" &>/dev/null; then
                missing_deps+=("$dep")
            fi
        done
        
        if [ ${#missing_deps[@]} -gt 0 ]; then
            echo -e "\033[1;33mWarning: Some recommended Wine dependencies may be missing.\e[0m"
            echo "For optimal Photoshop performance, consider installing:"
            echo "  sudo pacman -S ${missing_deps[*]}"
            echo ""
            echo "For complete dependency list, see README.md"
            echo ""
        else
            echo "✓ Recommended Wine dependencies are installed"
        fi
    fi
}

function preflight_check() {
    echo "=== Pre-flight Check ==="
    
    # Check Wine
    if ! check_wine_installation; then
        echo -e "\033[1;31mCannot proceed without Wine.\e[0m"
        exit 1
    fi
    
    # Check tools
    check_required_tools
    
    # Check/create symlink
    if ! check_wine_symlink; then
        echo -e "\033[1;31mFailed to setup Wine symlink.\e[0m"
        echo "Please ensure Wine is properly installed."
        exit 1
    fi
    
    # Check Wine dependencies (warning only)
    check_wine_dependencies
    
    echo "✓ Pre-flight check passed"
    echo ""
}

# ==================== WINE SYMLINK HANDLING ====================
# Function moved to scripts/sharedFuncs.sh

function main() {
    
    # Run pre-flight checks (Wine, dependencies, symlinks)
    preflight_check
    
    #print banner
    banner

    #read inputs
    read_input
    let answer=$?

    case "$answer" in

    1)  
        echo "run photoshop CC Installation..."
        echo -n "using winetricks for component installation..."
        run_script "scripts/PhotoshopSetup.sh" "PhotoshopSetup.sh"
        ;;
    2)  
        echo "run lightroom CC Installation..."
        echo -n "using lightroom installer..."
        run_script "scripts/lightroom.sh" "lightroom.sh"
        ;;
    3)  
        echo -n "run adobe camera Raw installer"
        run_script "scripts/cameraRawInstaller.sh" "cameraRawInstaller.sh"
        ;;
    4)  
        echo "run winecfg..."
        echo -n "open virtualdrive configuration..."
        run_script "scripts/winecfg.sh" "winecfg.sh"
        ;;
    5)  
        echo -n "uninstall photoshop CC ..."
        run_script "scripts/uninstaller.sh" "uninstaller.sh"
        ;;
    6)  
        echo "exit setup..."
        exitScript
        ;;
    esac
}

#argumaents 1=script_path 2=script_name 
function run_script() {
    local script_path=$1
    local script_name=$2

    wait_second 5
    if [ -f "$script_path" ];then
        echo "$script_path Found..."
        chmod +x "$script_path"
    else
        error "$script_name not Found..."    
    fi
    cd "./scripts/" && bash "$script_name"
    unset script_path
}

function wait_second() {
    for (( i=0 ; i<$1 ; i++ ));do
        echo -n "."
        sleep 1
    done
    echo ""
}

function read_input() {
    while true ;do
        read -p "[choose an option]$ " choose
        if [[ "$choose" =~ (^[1-6]$) ]];then
            break
        fi
        warning "choose a number between 1 to 6"
    done

    return $choose
}

function exitScript() {
    echo "Good Bye :)"
}

function banner() {
    local banner_path="$PWD/images/banner"
    if [ -f $banner_path ];then 
        clear && echo ""
        cat $banner_path
        echo ""
    else
        error "banner not Found..."
    fi
    unset banner_path
}



main

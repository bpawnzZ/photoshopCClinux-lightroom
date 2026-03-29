# Adobe Photoshop & Lightroom CC Setup Architecture

## 🎯 OVERVIEW

This document details the architecture and implementation of the Adobe Photoshop CC and Lightroom CC setup system for Linux using Wine. The system is designed to be **portable across different Linux distributions** and **intelligent about dependency management**.

## 📁 PROJECT STRUCTURE

```
photoshopCClinux/
├── setup.sh                    # Main menu script
├── scripts/
│   ├── sharedFuncs.sh          # Core functions library
│   ├── PhotoshopSetup.sh       # Photoshop installation
│   ├── lightroom.sh            # Lightroom installation  
│   ├── cameraRawInstaller.sh   # Camera Raw plugin
│   ├── winecfg.sh              # Wine configuration
│   ├── uninstaller.sh          # Uninstallation
│   ├── launcher.sh             # Application launcher
│   └── *.desktop               # Desktop entries
├── files/                      # Adobe installer packages
├── images/                     # Icons and banners
└── README.md                   # User documentation
```

## 🔧 CORE ARCHITECTURE PRINCIPLES

### 1. **Shared Wine Prefix**
- Both Photoshop and Lightroom share the **same Wine prefix** (`~/.photoshopCCV19/prefix/`)
- This allows them to share Windows dependencies (VC runtimes, .NET, etc.)
- Prevents duplicate dependency installation

### 2. **Intelligent Dependency Management**
- Checks if Wine prefix already exists
- Verifies which Windows dependencies are already installed
- Only installs missing dependencies
- Never deletes existing installations

### 3. **Portability Across Distributions**
- Auto-detects Linux distribution (Arch, Debian, Fedora, etc.)
- Detects package manager (pacman, apt, dnf, yum, zypper)
- Provides distribution-specific installation instructions
- Handles 32-bit architecture enablement automatically

### 4. **Robust Error Handling**
- Pre-flight checks before any installation
- Clear error messages with actionable solutions
- Graceful fallbacks when system-wide operations fail
- User-local symlink creation when sudo is unavailable

## 🧩 KEY COMPONENTS

### `setup.sh` - Main Entry Point
- **Purpose**: Menu-driven interface for users
- **Key Features**:
  - Pre-flight dependency checking
  - Distro detection and package manager identification
  - Wine verification with installation guidance
  - Calls appropriate installation scripts

### `scripts/sharedFuncs.sh` - Core Function Library
- **Purpose**: Centralized functions used by all scripts
- **Key Functions**:

#### **Distribution & Package Management**
```bash
detect_distro()              # Detects 20+ Linux distributions
detect_package_manager()     # Identifies package manager
check_package()              # Checks if package is installed
install_packages()           # Installs packages using correct package manager
```

#### **Wine Management**
```bash
check_install_wine()         # Comprehensive Wine installation
check_wine_symlink()         # Creates wine->wine64 symlink with fallbacks
get_wine_dependencies()      # Returns distro-specific dependency lists
check_32bit_support()        # Verifies 32-bit library support
```

#### **Intelligent Dependency System** (NEW)
```bash
check_wine_prefix()          # Checks if Wine prefix exists and is valid
check_winetricks_component() # Checks if specific component is installed
get_adobe_dependencies()     # Returns common Adobe dependencies
install_missing_dependencies() # Installs only missing dependencies
check_adobe_app_installed()  # Checks if app is already installed
safe_create_dir()            # Creates directory without deleting existing
```

#### **Utility Functions**
```bash
package_installed()          # Checks if command exists in PATH
rmdir_if_exist()             # Deletes and recreates directory (CAUTION)
export_var()                 # Sets Wine environment variables
launcher()                   # Creates desktop entries and launchers
set_dark_mod()               # Applies dark theme to Wine prefix
```

### `scripts/PhotoshopSetup.sh` & `scripts/lightroom.sh`
- **Purpose**: Application-specific installation
- **Key Logic**:
  1. Check if application is already installed (asks before reinstall)
  2. Set Wine environment variables
  3. Call `install_missing_dependencies()` - intelligently installs only what's needed
  4. Extract and run Adobe installer
  5. Add Adobe license server blocks to hosts file
  6. Create launcher and desktop entry

### `scripts/cameraRawInstaller.sh`
- **Purpose**: Installs Adobe Camera Raw plugin
- **Key Logic**: Requires Photoshop to be installed first, installs into existing prefix

### `scripts/uninstaller.sh`
- **Purpose**: Complete uninstallation
- **Key Logic**: Deletes Wine prefix, launchers, desktop entries (with user confirmation)

## 🔄 INSTALLATION WORKFLOW

### Scenario 1: Fresh Installation (No Wine)
```
User runs: ./setup.sh
1. setup.sh detects no Wine installation
2. Shows distro-specific Wine installation commands
3. User installs Wine manually
4. User runs ./setup.sh again
5. Pre-flight checks pass
6. User selects "Install Photoshop"
7. PhotoshopSetup.sh creates new Wine prefix
8. Installs all Windows dependencies via winetricks
9. Installs Photoshop
```

### Scenario 2: Install Lightroom after Photoshop
```
User runs: ./setup.sh
1. Pre-flight checks pass (Wine is installed)
2. User selects "Install Lightroom"
3. lightroom.sh detects existing Wine prefix
4. Checks which dependencies are already installed
5. Finds all dependencies already installed (from Photoshop)
6. Skips dependency installation
7. Installs Lightroom into existing prefix
```

### Scenario 3: Install Photoshop after Lightroom
```
User runs: ./setup.sh
1. Pre-flight checks pass
2. User selects "Install Photoshop"
3. PhotoshopSetup.sh detects existing Wine prefix
4. Checks dependencies - all already installed from Lightroom
5. Skips dependency installation
6. Installs Photoshop into existing prefix
```

## 🛠️ DEPENDENCY RESOLUTION

### Windows Dependencies (via winetricks)
Both applications require:
- `atmlib` - Adobe Type Manager
- `fontsmooth=rgb` - Font smoothing
- `vcrun2008`, `vcrun2010`, `vcrun2012`, `vcrun2013` - Visual C++ runtimes
- `msxml3`, `msxml6` - XML parsers

### Linux Dependencies
- **Wine** (wine-staging recommended)
- **winetricks** (for Windows component installation)
- **Download tools**: aria2c, curl, or wget
- **32-bit libraries** (for 64-bit Wine to work properly)

## 🚨 CRITICAL DESIGN DECISIONS

### 1. **Never Delete Existing Wine Prefix**
- Old behavior: Each script deleted and recreated the Wine prefix
- **New behavior**: Check if prefix exists, reuse it
- **Why**: Prevents losing existing installations and duplicate work

### 2. **Check Before Install**
- Old behavior: Always install all dependencies
- **New behavior**: Check registry for installed components
- **Why**: Faster installations, less network usage

### 3. **User-Local Fallbacks**
- Old behavior: Require sudo for symlink creation
- **New behavior**: Try user-local symlink if sudo fails
- **Why**: Works on restricted systems or without sudo access

### 4. **Distribution Awareness**
- Old behavior: Assume Arch Linux
- **New behavior**: Detect distribution, provide appropriate commands
- **Why**: Portable across different Linux distributions

## 🔍 DEBUGGING & TROUBLESHOOTING

### Log Files
- `~/.photoshopCCV19/wine-error.log` - Wine errors and output
- `~/.photoshopCCV19/setuplog.log` - Installation progress
- `~/.photoshop-setup.log` - Fallback log if SCR_PATH not set

### Common Issues

#### "wine64: command not found"
- **Cause**: Wine not installed or symlink missing
- **Solution**: Enhanced `check_wine_symlink()` function checks for:
  - `wine` command in PATH
  - `wine64` binary (creates symlink)
  - `wine-staging` binary (creates symlink)
  - User-local fallback if system-wide fails

#### Missing 32-bit Libraries
- **Cause**: 64-bit system without 32-bit support
- **Solution**: `check_32bit_support()` warns and guides user

#### Dependency Installation Failures
- **Cause**: Network issues or missing repositories
- **Solution**: Scripts include retry logic and multiple download tools

## 📈 FUTURE ENHANCEMENTS

### Potential Improvements
1. **Automatic Wine Installation**: Currently gives instructions, could install automatically
2. **Dependency Version Checking**: Verify specific versions of installed components
3. **Update Mechanism**: Check for updates to Adobe applications
4. **Multiple Prefix Support**: Allow different Wine prefixes for different Adobe versions
5. **GUI Interface**: Graphical frontend for the setup process

### Testing Strategy
1. **Fresh System Test**: No Wine installed
2. **Photoshop First Test**: Install Photoshop, then Lightroom
3. **Lightroom First Test**: Install Lightroom, then Photoshop
4. **Reinstall Test**: Reinstall already installed application
5. **Cross-Distro Test**: Arch, Ubuntu, Fedora, openSUSE

## 🎯 HANDOFF NOTES FOR LLM AGENTS

### Critical Context for Maintenance
1. **Wine Prefix Location**: `~/.photoshopCCV19/prefix/` - Shared by both applications
2. **Dependency Checking**: Uses Wine registry (`system.reg`, `user.reg`) to check installed components
3. **Fallback Chains**: Multiple fallbacks for symlinks, download tools, directory creation
4. **User Confirmation**: Always ask before destructive operations (uninstall, reinstall)

### Code Patterns to Maintain
- **Function Naming**: `check_*()` for verification, `install_*()` for installation
- **Error Handling**: Use `error()` function for fatal errors, `warning()` for non-fatal
- **Message Display**: Use `show_message()` for consistent output formatting
- **Path Variables**: `SCR_PATH`, `CACHE_PATH`, `WINE_PREFIX`, `RESOURCES_PATH`

### Testing Requirements
- Test installation order permutations
- Test on different Linux distributions
- Test with and without sudo access
- Test network failure scenarios

### Security Considerations
- Never run as root (scripts warn against this)
- Verify checksums of downloaded files
- User confirmation for destructive operations
- Safe path handling to prevent injection

## 📚 RELATED DOCUMENTATION

- `README.md` - User-facing documentation
- `TEST_PLAN.md` - Comprehensive test cases
- `test_package_functions.sh` - Function validation script
- Git commit history - Evolution of fixes and improvements

## 🏁 CONCLUSION

This architecture provides a **robust, portable, and intelligent** setup system for Adobe applications on Linux. The key innovation is the **intelligent dependency management** that prevents duplicate installations and preserves existing setups while maintaining cross-distro compatibility.

**Maintenance Priority**: Preserve the shared Wine prefix principle and intelligent dependency checking, as these are the core innovations that differentiate this solution from typical Wine application setups.
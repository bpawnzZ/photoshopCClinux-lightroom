# Package Dependency Automation Test Plan

## Overview
This test plan validates the package dependency checking and installation system for Photoshop CC on Linux across different distributions.

## Test Environment Requirements
- Multiple Linux distributions (or VMs/containers)
- Internet connection for package downloads
- sudo/root access for package installation

## Test Cases

### 1. Distro Detection Function
**Objective**: Verify correct detection of Linux distribution and package manager.

| Test Case | Expected Result |
|-----------|-----------------|
| Arch Linux | Detects as "arch" with "pacman" |
| Ubuntu/Debian | Detects as "ubuntu"/"debian" with "apt" |
| Fedora | Detects as "fedora" with "dnf" |
| openSUSE | Detects as "opensuse" with "zypper" |
| Unknown distro | Returns "unknown" with fallback |

### 2. Package Installation Function
**Objective**: Verify package installation works with different package managers.

| Test Case | Expected Result |
|-----------|-----------------|
| Install single package | Package installed successfully |
| Install multiple packages | All packages installed |
| Package already installed | Skips installation, returns success |
| Invalid package name | Returns error, continues with others |
| No sudo access | Falls back to user installation where possible |

### 3. Wine Dependency Checking
**Objective**: Verify Wine and dependency detection/installation.

| Test Case | Expected Result |
|-----------|-----------------|
| Wine already installed | Skips installation, reports version |
| Wine not installed | Installs Wine + distro-specific dependencies |
| Wine64 without wine symlink | Creates wine -> wine64 symlink |
| 32-bit arch not enabled (Debian) | Enables i386 architecture automatically |
| Missing multilib (Arch) | Warns user to enable multilib |

### 4. Distribution-Specific Dependencies
**Objective**: Verify correct dependency lists for each distribution.

| Distribution | Key Dependencies to Verify |
|--------------|---------------------------|
| Arch Linux | wine-staging, lib32-* packages, giflib, libpng, etc. |
| Debian/Ubuntu | winehq-staging, winetricks, enables i386 |
| Fedora/RHEL | wine, winetricks |
| Generic fallback | wine, winetricks |

### 5. Integration with setup.sh
**Objective**: Verify dependency checking integrates with main setup flow.

| Test Case | Expected Result |
|-----------|-----------------|
| Run setup.sh without Wine | Installs Wine first, then continues |
| Run setup.sh with Wine | Skips to main menu |
| Missing winetricks | Warns user but continues |
| Network issues | Provides clear error message |

### 6. Error Handling
**Objective**: Verify graceful error handling.

| Test Case | Expected Result |
|-----------|-----------------|
| No internet connection | Clear error message, suggests manual install |
| Package repository error | Warns user, suggests manual steps |
| Permission denied | Suggests running with sudo or manual steps |
| Disk space full | Clear error message, exits gracefully |

## Test Execution

### Quick Test (Single Distribution)
1. Backup current Wine installation (if any)
2. Remove Wine: `sudo pacman -Rns wine wine-staging` (or equivalent)
3. Run: `./setup.sh`
4. Verify Wine is installed automatically
5. Verify dependency packages are installed
6. Verify wine symlink is created
7. Run Photoshop installation option

### Cross-Distribution Testing
For each supported distribution:
1. Fresh install/VM of the distribution
2. Run `./setup.sh` without any pre-installed packages
3. Document any issues or missing dependencies
4. Verify Photoshop installation works after dependency setup

## Success Criteria
1. ✅ Wine installed automatically on fresh system
2. ✅ All required dependencies installed for the distribution
3. ✅ Proper wine/wine64 symlink created
4. ✅ Photoshop installation proceeds without package errors
5. ✅ Clear error messages for any failures
6. ✅ Works on at least 3 major distributions (Arch, Ubuntu, Fedora)

## Confidence Score: 8/10

**Strengths**:
- Comprehensive distro detection
- Automatic dependency installation
- Graceful error handling
- Support for major package managers
- Integration with existing codebase

**Areas for Improvement**:
- Needs testing on actual different distributions
- Could add support for more niche package managers (Nix, Guix)
- Could include automatic detection of GPU drivers for better performance

## Implementation Notes

The package automation system includes:
1. `detect_distro()` - Detects Linux distribution and package manager
2. `check_package()` - Checks if a package is installed
3. `install_packages()` - Installs packages using appropriate package manager
4. `get_wine_dependencies()` - Returns distro-specific Wine dependencies
5. `check_install_wine()` - Main function to check/install Wine and dependencies
6. `check_wine_symlink()` - Enhanced symlink creation with backup
7. `check_32bit_support()` - Checks and warns about 32-bit library support

All functions are added to `scripts/sharedFuncs.sh` and integrated into `setup.sh`.
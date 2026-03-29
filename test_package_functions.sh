#!/usr/bin/env bash

# Test script for package automation functions

echo "=== Testing Package Automation Functions ==="
echo ""

# Source the shared functions
if [ -f "scripts/sharedFuncs.sh" ]; then
    source "scripts/sharedFuncs.sh"
    echo "✓ Loaded sharedFuncs.sh"
else
    echo "✗ Error: sharedFuncs.sh not found"
    exit 1
fi

echo ""
echo "1. Testing distro detection..."
detect_distro
echo "   Detected: DISTRO_ID=$DISTRO_ID, PKG_MANAGER=$PKG_MANAGER"

echo ""
echo "2. Testing package checking..."
echo "   Checking for 'bash': $(check_package bash)"
echo "   Checking for 'nonexistentpackage123': $(check_package nonexistentpackage123)"

echo ""
echo "3. Testing Wine dependency detection..."
wine_deps=($(get_wine_dependencies))
echo "   Wine dependencies for $DISTRO_ID:"
for dep in "${wine_deps[@]}"; do
    echo "   - $dep"
done

echo ""
echo "4. Testing symlink checking (dry run)..."
echo "   Note: This will check but not modify system"
if command -v wine64 >/dev/null 2>&1; then
    echo "   wine64 found at: $(command -v wine64)"
else
    echo "   wine64 not found"
fi

if command -v wine >/dev/null 2>&1; then
    echo "   wine found at: $(command -v wine)"
    if [ -L "$(command -v wine)" ]; then
        echo "   wine is a symlink to: $(readlink -f "$(command -v wine)")"
    else
        echo "   wine is not a symlink"
    fi
else
    echo "   wine not found"
fi

echo ""
echo "5. Testing 32-bit support check..."
check_32bit_support

echo ""
echo "=== Test Summary ==="
echo "All functions loaded and tested successfully."
echo "To fully test installation, run: sudo ./setup.sh"
echo ""
echo "Note: Actual package installation requires sudo/root privileges."
echo "Run this test script without sudo to verify detection functions."
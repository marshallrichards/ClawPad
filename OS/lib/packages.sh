#!/bin/bash
# Package manager abstraction layer
# Provides unified interface for apt, pacman, etc.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/distro.sh"

# Package name mappings (base name -> distro-specific name)
# Format: base_name:debian_name:ubuntu_name:arch_name
declare -A PKG_MAP

# Load package mappings from file
load_package_map() {
    local map_file="$SCRIPT_DIR/../packages/mappings.txt"
    if [[ -f "$map_file" ]]; then
        while IFS=: read -r base debian ubuntu arch; do
            [[ "$base" =~ ^#.*$ || -z "$base" ]] && continue
            PKG_MAP["$base"]="$debian:$ubuntu:$arch"
        done < "$map_file"
    fi
}

# Translate a base package name to distro-specific name
translate_package() {
    local pkg="$1"

    if [[ -n "${PKG_MAP[$pkg]}" ]]; then
        IFS=: read -r debian ubuntu arch <<< "${PKG_MAP[$pkg]}"
        case "$DISTRO_ID" in
            debian) echo "${debian:-$pkg}" ;;
            ubuntu) echo "${ubuntu:-$debian:-$pkg}" ;;
            arch|manjaro|endeavouros) echo "${arch:-$pkg}" ;;
            *) echo "$pkg" ;;
        esac
    else
        echo "$pkg"
    fi
}

# Update package database
pkg_update() {
    case "$DISTRO_FAMILY" in
        debian)
            sudo apt update
            ;;
        arch)
            sudo pacman -Sy
            ;;
        *)
            echo "Unsupported distro family: $DISTRO_FAMILY" >&2
            return 1
            ;;
    esac
}

# Install packages (accepts base package names)
pkg_install() {
    local packages=()
    for pkg in "$@"; do
        packages+=("$(translate_package "$pkg")")
    done

    case "$DISTRO_FAMILY" in
        debian)
            sudo apt install -y "${packages[@]}"
            ;;
        arch)
            sudo pacman -S --noconfirm "${packages[@]}"
            ;;
        *)
            echo "Unsupported distro family: $DISTRO_FAMILY" >&2
            return 1
            ;;
    esac
}

# Install packages from a file (one per line, comments with #)
pkg_install_from_file() {
    local file="$1"
    local packages=()

    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        # Extract package name (first word)
        pkg=$(echo "$line" | awk '{print $1}')
        [[ -n "$pkg" ]] && packages+=("$pkg")
    done < "$file"

    if [[ ${#packages[@]} -gt 0 ]]; then
        pkg_install "${packages[@]}"
    fi
}

# Check if a package is installed
pkg_is_installed() {
    local pkg="$(translate_package "$1")"

    case "$DISTRO_FAMILY" in
        debian)
            dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"
            ;;
        arch)
            pacman -Qi "$pkg" &>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# Remove packages
pkg_remove() {
    local packages=()
    for pkg in "$@"; do
        packages+=("$(translate_package "$pkg")")
    done

    case "$DISTRO_FAMILY" in
        debian)
            sudo apt remove -y "${packages[@]}"
            ;;
        arch)
            sudo pacman -R --noconfirm "${packages[@]}"
            ;;
        *)
            echo "Unsupported distro family: $DISTRO_FAMILY" >&2
            return 1
            ;;
    esac
}

# Search for packages
pkg_search() {
    local query="$1"

    case "$DISTRO_FAMILY" in
        debian)
            apt search "$query"
            ;;
        arch)
            pacman -Ss "$query"
            ;;
        *)
            echo "Unsupported distro family: $DISTRO_FAMILY" >&2
            return 1
            ;;
    esac
}

# Upgrade all packages
pkg_upgrade() {
    case "$DISTRO_FAMILY" in
        debian)
            sudo apt update && sudo apt upgrade -y
            ;;
        arch)
            sudo pacman -Syu --noconfirm
            ;;
        *)
            echo "Unsupported distro family: $DISTRO_FAMILY" >&2
            return 1
            ;;
    esac
}

# Initialize package map on source
load_package_map

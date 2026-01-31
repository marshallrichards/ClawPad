#!/bin/bash
# Distro detection and identification
# Sources /etc/os-release for distro info

set -e

# Detect the current distribution
# Sets: DISTRO_ID, DISTRO_NAME, DISTRO_VERSION, DISTRO_FAMILY
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        DISTRO_ID="${ID}"
        DISTRO_NAME="${NAME}"
        DISTRO_VERSION="${VERSION_ID:-rolling}"

        # Determine family (for package manager selection)
        case "$DISTRO_ID" in
            debian|ubuntu|linuxmint|pop|elementary|zorin)
                DISTRO_FAMILY="debian"
                ;;
            arch|manjaro|endeavouros|garuda)
                DISTRO_FAMILY="arch"
                ;;
            fedora|rhel|centos|rocky|alma)
                DISTRO_FAMILY="redhat"
                ;;
            opensuse*|suse)
                DISTRO_FAMILY="suse"
                ;;
            *)
                DISTRO_FAMILY="unknown"
                ;;
        esac
    else
        DISTRO_ID="unknown"
        DISTRO_NAME="Unknown"
        DISTRO_VERSION="unknown"
        DISTRO_FAMILY="unknown"
    fi

    export DISTRO_ID DISTRO_NAME DISTRO_VERSION DISTRO_FAMILY
}

# Check if running a supported distro
is_supported() {
    detect_distro
    case "$DISTRO_FAMILY" in
        debian|arch)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Get a human-readable distro string
distro_string() {
    detect_distro
    echo "$DISTRO_NAME $DISTRO_VERSION ($DISTRO_FAMILY family)"
}

# Check for specific distro
is_debian() { [[ "$DISTRO_ID" == "debian" ]]; }
is_ubuntu() { [[ "$DISTRO_ID" == "ubuntu" ]]; }
is_arch() { [[ "$DISTRO_ID" == "arch" ]]; }

# Check for distro family
is_debian_family() { [[ "$DISTRO_FAMILY" == "debian" ]]; }
is_arch_family() { [[ "$DISTRO_FAMILY" == "arch" ]]; }

# Initialize on source
detect_distro

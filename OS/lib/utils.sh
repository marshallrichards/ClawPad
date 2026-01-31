#!/bin/bash
# Common utility functions for clawpad-os

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $*"
}

# Check if running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Do not run this script as root. It will use sudo when needed."
        exit 1
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Prompt for yes/no confirmation
confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-n}"

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi

    read -rp "$prompt" response
    response=${response:-$default}

    [[ "$response" =~ ^[Yy]$ ]]
}

# Create backup of a file
backup_file() {
    local file="$1"
    local backup_dir="${2:-$HOME/.clawpad-backups}"

    if [[ -f "$file" ]]; then
        mkdir -p "$backup_dir"
        local backup_name="$(basename "$file").$(date +%Y%m%d-%H%M%S).bak"
        cp "$file" "$backup_dir/$backup_name"
        log_info "Backed up $file to $backup_dir/$backup_name"
    fi
}

# Symlink with backup
safe_symlink() {
    local source="$1"
    local target="$2"

    if [[ -e "$target" && ! -L "$target" ]]; then
        backup_file "$target"
    fi

    ln -sf "$source" "$target"
    log_success "Linked $target -> $source"
}

# Copy with backup
safe_copy() {
    local source="$1"
    local target="$2"

    if [[ -e "$target" ]]; then
        backup_file "$target"
    fi

    mkdir -p "$(dirname "$target")"
    cp -r "$source" "$target"
    log_success "Copied $source to $target"
}

# Append to file if content not already present
append_if_missing() {
    local file="$1"
    local content="$2"
    local marker="${3:-# clawpad-os}"

    if ! grep -qF "$marker" "$file" 2>/dev/null; then
        echo "" >> "$file"
        echo "$marker" >> "$file"
        echo "$content" >> "$file"
        log_success "Appended content to $file"
    else
        log_info "Content already present in $file"
    fi
}

# Ensure a directory exists
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_info "Created directory: $dir"
    fi
}

# Get the repo root directory
get_repo_root() {
    local script_path="${BASH_SOURCE[0]}"
    local script_dir="$(cd "$(dirname "$script_path")" && pwd)"
    echo "$(dirname "$script_dir")"
}

# Check if running in a graphical environment
has_display() {
    [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]
}

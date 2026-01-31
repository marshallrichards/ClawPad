#!/bin/bash
# ClawPad-OS Installer
# Installs i3wm-based desktop environment on Debian, Ubuntu, or Arch Linux

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source library files
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/distro.sh"
source "$SCRIPT_DIR/lib/packages.sh"

# Configuration
INSTALL_OPTIONAL=false
INSTALL_NVIM=false
DRY_RUN=false
SKIP_PACKAGES=false
NO_BACKUP=false

usage() {
    cat << EOF
ClawPad-OS Installer

Usage: $(basename "$0") [OPTIONS]

Options:
    -h, --help          Show this help message
    -o, --optional      Also install optional packages (media, office, dev tools)
    --nvim              Install LazyVim neovim configuration
    -n, --dry-run       Show what would be done without making changes
    -s, --skip-packages Skip package installation (config only)
    --no-backup         Don't backup existing config files

Examples:
    $(basename "$0")              # Install base packages and configs
    $(basename "$0") -o           # Install with optional packages
    $(basename "$0") --nvim       # Include neovim configuration
    $(basename "$0") -o --nvim    # Full installation with all extras
    $(basename "$0") -n           # Dry run - see what would happen
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -o|--optional)
            INSTALL_OPTIONAL=true
            shift
            ;;
        --nvim)
            INSTALL_NVIM=true
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -s|--skip-packages)
            SKIP_PACKAGES=true
            shift
            ;;
        --no-backup)
            NO_BACKUP=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Preflight checks
preflight() {
    log_step "Running preflight checks..."

    check_not_root

    if ! is_supported; then
        log_error "Unsupported distribution: $(distro_string)"
        log_error "Supported: Debian, Ubuntu, Arch Linux (and derivatives)"
        exit 1
    fi

    log_success "Detected: $(distro_string)"
}

# Install packages
install_packages() {
    if [[ "$SKIP_PACKAGES" == true ]]; then
        log_info "Skipping package installation (--skip-packages)"
        return
    fi

    log_step "Updating package database..."
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would run: pkg_update"
    else
        pkg_update
    fi

    log_step "Installing base packages..."
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would install packages from: $SCRIPT_DIR/packages/base.txt"
    else
        pkg_install_from_file "$SCRIPT_DIR/packages/base.txt"
    fi

    if [[ "$INSTALL_OPTIONAL" == true ]]; then
        log_step "Installing optional packages..."
        if [[ "$DRY_RUN" == true ]]; then
            log_info "[DRY RUN] Would install packages from: $SCRIPT_DIR/packages/optional.txt"
        else
            pkg_install_from_file "$SCRIPT_DIR/packages/optional.txt"
        fi
    fi

    log_success "Package installation complete"
}

# Install configuration files
install_configs() {
    log_step "Installing configuration files..."

    # i3 config
    ensure_dir "$HOME/.config/i3"
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would copy i3 config to ~/.config/i3/config"
    else
        safe_copy "$SCRIPT_DIR/config/i3/config" "$HOME/.config/i3/config"
    fi

    # Wallpaper
    if [[ -f "$SCRIPT_DIR/assets/wallpaper.png" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log_info "[DRY RUN] Would copy wallpaper to ~/.config/i3/wallpaper.png"
        else
            safe_copy "$SCRIPT_DIR/assets/wallpaper.png" "$HOME/.config/i3/wallpaper.png"
        fi
    fi

    # Bashrc additions
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would append to ~/.bashrc"
    else
        append_if_missing "$HOME/.bashrc" "$(cat "$SCRIPT_DIR/config/bashrc.append")" "# === ClawPad-OS ==="
    fi

    log_success "Configuration files installed"
}

# Install neovim configuration
install_nvim_config() {
    if [[ "$INSTALL_NVIM" != true ]]; then
        return
    fi

    log_step "Installing neovim configuration (LazyVim)..."
    log_warn "Note: This config uses ~30 plugins and may be slow on older hardware"
    log_info "      Heavy plugins (Copilot, treesitter, noice) are disabled by default"

    ensure_dir "$HOME/.config/nvim"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would copy nvim config to ~/.config/nvim/"
    else
        # Backup existing config
        if [[ -d "$HOME/.config/nvim" && -f "$HOME/.config/nvim/init.lua" ]]; then
            backup_file "$HOME/.config/nvim/init.lua"
        fi

        # Copy nvim configuration
        cp "$SCRIPT_DIR/config/nvim/init.lua" "$HOME/.config/nvim/init.lua"
        cp "$SCRIPT_DIR/config/nvim/stylua.toml" "$HOME/.config/nvim/stylua.toml"
        cp -r "$SCRIPT_DIR/config/nvim/lua" "$HOME/.config/nvim/"

        log_success "Neovim configuration installed"
        log_info "  First launch will install plugins automatically (may take a minute)"
        log_info "  To re-enable heavy plugins, edit ~/.config/nvim/lua/plugins/disabled.lua"
    fi
}

# Install scripts
install_scripts() {
    log_step "Installing scripts..."

    ensure_dir "$HOME/.local/bin"

    for script in "$SCRIPT_DIR/scripts/"*; do
        if [[ -f "$script" ]]; then
            local name=$(basename "$script")
            if [[ "$DRY_RUN" == true ]]; then
                log_info "[DRY RUN] Would install script: $name"
            else
                cp "$script" "$HOME/.local/bin/$name"
                chmod +x "$HOME/.local/bin/$name"
                log_success "Installed script: $name"
            fi
        fi
    done

    log_success "Scripts installed"
}

# Post-install tasks
post_install() {
    log_step "Running post-install tasks..."

    # Enable i3 as default session (if not already)
    if [[ "$DRY_RUN" != true ]]; then
        # Create .xinitrc for startx users
        if [[ ! -f "$HOME/.xinitrc" ]]; then
            echo "exec i3" > "$HOME/.xinitrc"
            log_success "Created ~/.xinitrc"
        fi
    fi

    log_info ""
    log_info "========================================"
    log_success "ClawPad-OS installation complete!"
    log_info "========================================"
    log_info ""
    log_info "Next steps:"
    log_info "  1. Log out and select i3 as your session"
    log_info "  2. Or run 'startx' if using a minimal setup"
    log_info ""
    log_info "Key bindings:"
    log_info "  Mod+Return    Open terminal"
    log_info "  Mod+d         Application launcher"
    log_info "  Mod+q         Close window"
    log_info "  Mod+Shift+e   Exit i3"
    log_info ""

    if [[ "$INSTALL_NVIM" == true ]]; then
        log_info "Neovim:"
        log_info "  Run 'nvim' to complete plugin installation"
        log_info "  Plugins will auto-install on first launch"
        log_info ""
    fi
}

# Main
main() {
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║       ClawPad-OS Installer            ║"
    echo "║   i3wm Desktop Environment Setup      ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""

    preflight

    if [[ "$DRY_RUN" == true ]]; then
        log_warn "DRY RUN MODE - No changes will be made"
        echo ""
    fi

    # Show what will be installed
    log_info "Installation summary:"
    log_info "  - Base packages and i3 config: Yes"
    log_info "  - Optional packages: $([ "$INSTALL_OPTIONAL" == true ] && echo "Yes" || echo "No")"
    log_info "  - Neovim config: $([ "$INSTALL_NVIM" == true ] && echo "Yes (LazyVim)" || echo "No")"
    echo ""

    if ! confirm "Proceed with installation?"; then
        log_info "Installation cancelled"
        exit 0
    fi

    install_packages
    install_configs
    install_nvim_config
    install_scripts
    post_install
}

main "$@"

# ClawPad-OS

A distro-agnostic i3wm desktop environment configuration. LARBS-inspired with modern tooling.

## Supported Distributions

- **Debian** 12+ (Bookworm, Trixie)
- **Ubuntu** 22.04+ (including derivatives like Pop!_OS, Linux Mint)
- **Arch Linux** (including Manjaro, EndeavourOS)

## Quick Install

```bash
git clone https://github.com/marshallrichards/clawpad-os.git
cd clawpad-os
./install.sh
```

### Install Options

```bash
./install.sh              # Base installation
./install.sh -o           # Include optional packages (media, office, dev tools)
./install.sh --nvim       # Include neovim configuration (LazyVim)
./install.sh -o --nvim    # Full installation with all extras
./install.sh -n           # Dry run (see what would happen)
./install.sh -s           # Skip packages, config only
```

## What's Included

### Window Manager
- **i3wm** with gaps, vim-like keybindings
- **picom** compositor for transparency/shadows
- **rofi** application launcher
- **dunst** notifications
- **i3lock** screen locker

### Rofi Power Tools
- `Mod+d` - Application launcher
- `Mod+Shift+x` - Power menu (shutdown/reboot/suspend/lock)
- `Mod+c` - Clipboard history
- `Mod+i` - WiFi menu
- `Mod+Shift+b` - Bluetooth menu
- `Mod+equal` - Calculator
- `Mod+period` - Emoji picker
- `Mod+o` - File finder
- `Mod+/` - Content search

### Key Bindings (LARBS-style)

| Key | Action |
|-----|--------|
| `Mod+Return` | Terminal (alacritty) |
| `Mod+q` | Close window |
| `Mod+d` | App launcher |
| `Mod+hjkl` | Focus (vim-style) |
| `Mod+Shift+hjkl` | Move window |
| `Mod+1-0` | Switch workspace |
| `Mod+Shift+1-0` | Move to workspace |
| `Mod+f` | Fullscreen |
| `Mod+v` | Toggle split direction |
| `Mod+r` | Resize mode |
| `Mod+Shift+c` | Reload i3 config |
| `Mod+Shift+r` | Restart i3 |

### Modern CLI Tools
- **eza** (ls replacement with icons)
- **bat** (cat with syntax highlighting)
- **ripgrep** (fast grep)
- **fd** (fast find)
- **fzf** (fuzzy finder)
- **btop** (resource monitor)
- **trash-cli** (safe rm)

### Neovim Configuration (Optional)

Install with `--nvim` flag. Based on **LazyVim** with ~30 plugins.

**Performance note**: Heavy plugins are disabled by default for older hardware:
- Copilot (AI completion) — disabled
- Treesitter (syntax parsing) — disabled, uses vim's built-in highlighting
- noice.nvim (fancy UI) — disabled

To re-enable, edit `~/.config/nvim/lua/plugins/disabled.lua`.

**Included plugins**: LSP support, completion (blink.cmp), file navigation, git integration, surround, autopairs, which-key, and more.

## Directory Structure

```
clawpad-os/
├── install.sh           # Main installer
├── lib/
│   ├── distro.sh       # Distro detection
│   ├── packages.sh     # Package manager abstraction
│   └── utils.sh        # Helper functions
├── packages/
│   ├── base.txt        # Core packages
│   ├── optional.txt    # Optional packages
│   └── mappings.txt    # Package name mappings per distro
├── config/
│   ├── i3/config       # i3 configuration
│   ├── nvim/           # Neovim config (LazyVim-based)
│   └── bashrc.append   # Bash additions
├── scripts/            # Rofi menus and utilities
└── assets/
    └── wallpaper.png
```

## Customization

### Theme Colors (JetBrains Dark)
The config uses JetBrains IDE dark theme colors. Edit `~/.config/i3/config` to change:

```
set $bg       #1e1f22
set $fg       #bcbec4
set $blue     #3574f0
...
```

### Adding Packages
Add to `packages/base.txt` or `packages/optional.txt`. Use base names from `packages/mappings.txt` for cross-distro compatibility.

### Package Mapping
If a package has different names across distros, add to `packages/mappings.txt`:
```
# base_name:debian_name:ubuntu_name:arch_name
my-package:my-package-deb:my-package-deb:my-package-arch
```

## Post-Install

1. Log out and select **i3** as your session
2. Or run `startx` if using a minimal setup
3. Press `Mod+Return` to open a terminal
4. Press `Mod+d` to launch applications

## Backups

Existing configs are backed up to `~/.clawpad-backups/` before being replaced.

## Requirements

- X11 (Wayland not currently supported)
- systemd (for power management)
- NetworkManager (for WiFi menu)
- PulseAudio or PipeWire (for audio)

## License

MIT

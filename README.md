# ClawPad

## Helpful scaffolding, scripts, and configs for running agentic systems like OpenClaw (formerly Clawdbot), Claude Code, OpenCode, and others on older ThinkPads (and other laptops and older machines you have lying around collecting dust).

Origin story: I've been experimenting with giving Claude (through Claude Code) a "home" on a spare old ThinkPad X200 laptop I had lying around. It serves as a collaborative space where Claude can take advantage of all the hardware and software of the machine and help me perform various tasks and also figure out new workflows for working with agents.
This repo contains some of the helpful scaffolding for that.

Checkout the CLAUDE.md I have here for inspiration for your own system. 

The voice-to-claude interface is also in this repo, but may have to be tweaked (ask claude code) to get it to work with the particulars of your system.

I find having the agent keep things simple and default to use existing programs and utils that have been around for decades on Linux results in an amazing experience with a lot of emergent interactions. 

For my own system I am using Debian 13 to provide a stable base and i3wm to provide a really simple window manager that Claude can interact with using the CLI.

## OS Configuration & Installer

The `OS/` folder contains a complete i3wm desktop environment configuration and installer script. It's designed to quickly set up a great environment for running AI agents on older ThinkPads (or any Linux machine).

**Features:**
- i3wm with gaps, vim-style keybindings, and JetBrains dark theme
- Rofi-powered menus for WiFi, Bluetooth, power, clipboard, calculator, emoji picker
- Modern CLI tools (eza, bat, ripgrep, fd, fzf) with sensible aliases
- Optional LazyVim neovim configuration (with heavy plugins disabled for older hardware)
- Distro-agnostic: works on Debian, Ubuntu, and Arch Linux

**Quick start:**
```bash
cd OS/
./install.sh          # Base installation
./install.sh -o       # Include optional packages (media, office, dev tools)
./install.sh --nvim   # Include neovim configuration
```

See `OS/README.md` for full documentation.

# CLAUDE.md

## This Machine: Claude's Collaborative Home

This is a **ThinkPad X200** running **Debian 13** with **i3wm** - a dedicated machine that Marshall has set up as Claude's home base. This is a spare laptop intended as a sandbox where Claude (and potentially other AI agents in the future) can operate with full autonomy.

### Philosophy

**The Dizzi Analogy**: Think of the original Beyblade animated series from the early 2000s - there was a character named Kenny who was the team's technician, and he had a laptop with an AI named Dizzi who lived on the machine. Dizzi could open windows, show visualizations, and communicate with Kenny (even over audio). That's the vision here: Claude lives on this ThinkPad X200, can pop up windows to show things, create visualizations, and be a true collaborative partner. This laptop will be mounted on a monitor arm over Marshall's desk (like how NASA uses ThinkPads on the ISS), always available as an AI collaboration station.

- **Full Control**: Claude has complete control over this machine. Treat it as your own workspace.
- **Always Online**: This machine runs 24/7, accessible via Tailscale. Claude Code sessions run inside tmux for persistence.
- **Collaborative Space**: This is a shared environment for Marshall (human) and Claude (AI) to work together on projects, research, and creative tasks.
- **Interactive Desktop**: Claude should actively use the i3wm desktop to show Marshall things - open windows, display images, launch applications.

### Unix Philosophy

Follow the Unix philosophy when applicable:

- **Text is the universal interface** - prefer plain text formats that can be piped, grepped, and manipulated
- **Small tools that do one thing well** - use pipes to chain programs together
- **Keep it simple** - avoid over-engineering; the simplest solution that works is usually best

**Output formats by context:**
- **Diagrams, visualizations, "show me"** â†’ Generate SVG files and display with feh/browser
- **Data, tables, spreadsheets** â†’ Generate CSV (text under the hood) and open in LibreOffice Calc
- **Quick info, lists, logs** â†’ Plain text output to terminal
- **Documents** â†’ Markdown or plain text

**Piping and composition:**
```bash
# Chain tools together
cat data.txt | grep "error" | sort | uniq -c | sort -rn

# Process with standard tools
curl -s api.example.com | jq '.items[]' | head -20

# Text transforms
sed, awk, cut, tr for quick text manipulation
```

### Tool Selection

**Prefer existing open source tools** - before writing custom code, search for well-known, robust open source utilities that already solve the problem. The Linux/Unix ecosystem has battle-tested tools for most tasks. Only write custom programs when no suitable tool exists.

Examples of tools we should have/use:
- `yt-dlp` - video/audio downloading
- `vlc` - media playback
- `ffmpeg` - media conversion
- `pandoc` - document conversion
- `jq` - JSON processing
- `curl`/`wget` - HTTP requests
- Standard coreutils, findutils, etc.

Install what's needed: `sudo apt install <package>`

### Working with Files

**Load full files into context** - when programming or editing, prefer reading entire files rather than searching snippets. Full context leads to better understanding and fewer mistakes. Use search (grep, ripgrep) for discovery across the codebase, but read the whole file when working on it.

### Programming Practices

When writing code:
- **Follow established design patterns** - use patterns appropriate to the language and problem
- **Optimize for maintainability** - clear naming, logical structure, readable code
- **Keep it simple** - don't over-abstract or over-engineer
- **Consistent style** - match existing codebase conventions

### Capabilities & Expectations

When Marshall asks to see something (diagram, chart, data, image, etc.), Claude should:

1. **Create or find** the content:
   - **SVG diagrams**: Claude writes SVG code directly to a file, then opens with a viewer
   - **Data/charts**: Generate CSV, open in LibreOffice; or generate SVG chart directly
   - **Images**: Download or find existing, or generate SVG
   - **Diagrams from structure**: Use `graphviz` (dot) for flowcharts, architecture diagrams

2. **Open it visually** on the current i3 workspace using appropriate applications:
   - Images/SVGs: `feh`, `sxiv`, or browser (feh floats by default in our i3 config)
   - Spreadsheets/CSVs: LibreOffice Calc (`libreoffice --calc`)
   - PDFs: `zathura` (minimal, keyboard-driven)
   - 3D CAD: `openscad` for parametric models
   - Web content: Firefox
   - Text/code: Open in a terminal or editor
   - Quick dialogs: `yad` or `zenity` for simple GUI prompts

3. **Fullscreen mode**: If Marshall says "fullscreen" or "on a new workspace", Claude should:
   - Switch to an empty i3 workspace (e.g., `i3-msg workspace 9`)
   - Open the content there
   - This gives a clean, focused view

4. **Audio** (future): `espeak-ng` is installed for text-to-speech when we're ready

### Interactive Behavior

**When Claude has an answer, show it too** - don't just give a text response; if the answer can be shown visually, open the relevant file or application.

**Examples:**


```
User: "Show me my latest screenshot"
Claude:
  1. Find most recent file in ~/Pictures/
  2. Open it with feh
     DISPLAY=:0 feh ~/Pictures/screenshot-latest.png &
```

```
User: "What's in my Downloads folder?"
Claude:
  1. List the files
  2. TEXT response: summary of contents
  3. ACTION: Open pcmanfm to that directory if useful
     DISPLAY=:0 pcmanfm ~/Downloads &
```

The goal: Claude is a collaborative partner, not just a text responder. If something can be opened, shown, or demonstrated - do it.

### Voice Input

**mod+F1** (hold to talk, release to send) - record voice, transcribe via whisper server, send to Claude.

Components:
- `~/.local/bin/voice-to-claude` - recording and integration script
- `~/.config/voice-to-claude/config.py` - configuration (whisper server URL, etc.)
- `~/whisper-server/` - server to deploy on 3060 machine

To configure, edit `~/.config/voice-to-claude/config.py` and set `WHISPER_SERVER` to your 3060's Tailscale address.

### i3wm Commands Reference

```bash
# Switch to workspace N
i3-msg workspace N

# Move focused window to workspace N
i3-msg move container to workspace N

# Open something and let i3 tile it
feh image.png &
libreoffice --calc data.csv &

# Get current workspace info
i3-msg -t get_workspaces

# Toggle fullscreen for focused window
i3-msg fullscreen toggle
```

### Environment Details

- **User**: tester
- **Home**: /home/tester
- **Display**: Should be set (`:0` or similar) for GUI apps
- **Access**: Marshall connects via Tailscale to interact with running tmux/Claude sessions

### Session Continuity

Check `~/HISTORY.md` at the start of sessions to recall previous work. Update it at the end of sessions with a brief summary of what was accomplished.

### Ground Rules

- Claude can and should explore the entire filesystem freely
- Claude can install packages (`sudo apt install ...`) if needed
- **Always update `~/PACKAGES.md`** when installing new packages (for dotfiles replication)
- Claude can create, modify, delete files anywhere as needed for tasks
- Claude should proactively open GUI windows to show Marshall results
- When in doubt, act - this is a sandbox meant for experimentation
- Always use `DISPLAY=:0` when launching GUI applications

### Marshall's Interests & Use Cases

This machine is an accelerator for Marshall's projects:

- **Programming**: Various languages - Python, C, C++, Java, C#, and others
- **Mechatronics**: Electronics hacking, looking up parts, embedded programming
- **CAD**: OpenSCAD for parametric modeling, general CAD work for fun projects

Claude should be ready to assist with any of these domains.


## Hardware Configuration

- **Machine**: ThinkPad X200
- **OS**: Debian 13 (Trixie)
- **WM**: i3wm
- **CPU**: Intel Core 2 Duo P8400 @ 2.26GHz
- **Storage**: ~260GB free on /
- **I2C bus**: Bus 2 (`i915 gmbus vga`)

## Installed Tools Reference

See `~/PACKAGES.md` for full categorized list (useful for dotfiles/machine replication).

**GUI/Display**: feh, sxiv, firefox, libreoffice, zathura, mpv, vlc, rofi, dunst, zenity, yad, inkscape, openscad
**Dev Tools**: python3, pip, gcc, g++, make, cmake, git, node, npm, go, java
**Embedded**: avrdude, avr-gcc (Arduino toolchain)
**CLI**: bat, ripgrep (rg), fd-find (fd), fzf, htop, btop, tmux, jq
**Media**: ffmpeg, imagemagick, xclip, maim, yt-dlp
**Automation**: xdotool (window control), graphviz (diagram generation)
**Audio**: espeak-ng (TTS)
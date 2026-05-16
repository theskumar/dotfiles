# OmniWM Configuration Guide

> **Repo:** [BarutSRB/OmniWM](https://github.com/BarutSRB/OmniWM)
> **Config:** `omniwm/omniwm/settings.toml` → stowed to `~/.config/omniwm/settings.toml`
> **Float rules script:** `omniwm/setup-rules.sh` — run once after fresh install
> **Installed:** v0.4.9 via `brew install barutsrb/tap/omniwm` · check with `omniwmctl version`

OmniWM is a macOS tiling window manager inspired by Niri and Hyprland. It supports scrolling columns (Niri layout), BSP splitting (Dwindle layout), a quake drop-down terminal, clipboard history, command palette, and full IPC/CLI automation via `omniwmctl`.

---

## Table of Contents

- [Layouts](#layouts)
- [Configuration Sections](#configuration-sections)
  - [[general]](#general)
  - [[niri]](#niri)
  - [[dwindle]](#dwindle)
  - [[gaps]](#gaps)
  - [[borders]](#borders)
  - [[appearance]](#appearance)
  - [[workspaceBar]](#workspacebar)
  - [[focus]](#focus)
  - [[gestures]](#gestures)
  - [[quakeTerminal]](#quaketerminal)
  - [[mouseWarp]](#mousewarp)
  - [[clipboard]](#clipboard)
  - [[state]](#state)
  - [[statusBar]](#statusbar)
  - [[appRules]](#apprules)
  - [[hotkeys]](#hotkeys)
  - [[workspaces]](#workspaces)
- [Hotkey Reference](#hotkey-reference)
- [IPC & CLI (omniwmctl)](#ipc--cli-omniwmctl)
- [Float Rules Setup](#float-rules-setup)
- [Multi-Monitor Setup](#multi-monitor-setup)
- [Updating](#updating)

---

## Layouts

OmniWM supports two layout engines, switchable per workspace or globally:

| Layout | Description | Toggle |
|--------|-------------|--------|
| **Niri** | Scrolling columns — windows arranged in horizontal columns, pan left/right to reveal more | `Option+Shift+L` |
| **Dwindle** | BSP binary splitting — recursive halving like i3/bspwm | `Option+Shift+L` |

`defaultLayoutType` in `[general]` sets which layout new workspaces start with.

---

## Configuration Sections

### `[general]`

Core behaviour flags.

```toml
[general]
animationsEnabled = true       # Smooth window transition animations
defaultLayoutType = "niri"     # Default layout: "niri" | "dwindle"
hotkeysEnabled = true          # Enable/disable all global hotkeys
ipcEnabled = true              # Enable omniwmctl IPC automation
preventSleepEnabled = false    # Keep system awake while OmniWM is running
updateChecksEnabled = true     # Automatically check for new releases
```

---

### `[niri]`

Controls the scrolling columns layout.

```toml
[niri]
alwaysCenterSingleColumn = true        # Center the window when it's alone on the workspace
centerFocusedColumn = "never"          # Auto-scroll to focused column: "never" | "always" | "on-overflow"
columnWidthPresets = [0.333, 0.5, 0.66] # Width fractions cycled with Option+. / Option+,
defaultColumnWidth = 0.5               # Default width for newly created columns (v0.4.9+)
infiniteLoop = false                   # Wrap-around scroll at workspace edges
maxVisibleColumns = 2                  # How many columns are visible side-by-side at once
maxWindowsPerColumn = 3                # Max windows stacked vertically in one column
singleWindowAspectRatio = "4:3"        # Aspect ratio when a window is alone: "none" | "4:3" | "16:9" etc.
```

**Tips:**
- `centerFocusedColumn = "on-overflow"` is a good middle ground — only scrolls when the focused column is off-screen.
- `maxVisibleColumns = 3` works well on wide external monitors; `2` is ideal for a 14" MacBook.
- Set `singleWindowAspectRatio = "none"` to let single windows fill the available space freely.

---

### `[dwindle]`

Controls the BSP splitting layout.

```toml
[dwindle]
defaultSplitRatio = 1.0        # Default split ratio (1.0 = equal halves)
moveToRootStable = true        # Stabilise window position when moved to root
smartSplit = false             # Auto-choose split direction based on window shape
splitWidthMultiplier = 1.0     # Width bias for horizontal splits
useGlobalGaps = true           # Use the global [gaps] settings
singleWindowAspectRatio = "4:3"
```

---

### `[gaps]`

Space between windows and screen edges.

```toml
[gaps]
size = 4.0          # Inner gap between tiled windows (in points)

[gaps.outer]
top = 8.0           # Outer margin from the top screen edge
bottom = 8.0        # Outer margin from the bottom screen edge
left = 8.0          # Outer margin from the left screen edge
right = 8.0         # Outer margin from the right screen edge
```

**Tips:**
- On a Retina MacBook, `size = 4.0` is very tight. `8–12` is more comfortable.
- Set all `[gaps.outer]` to `0.0` to fill edge-to-edge (minus the workspace bar).

---

### `[borders]`

Highlight border on the focused window.

```toml
[borders]
enabled = true
width = 2.0          # Border thickness in points (canonical default: 5.0)

[borders.color]
red = 0.08
green = 0.20
blue = 0.48
alpha = 0.5          # 0.0 = transparent, 1.0 = opaque
```

Color values are in the 0.0–1.0 range (standard macOS CGFloat). `alpha = 0.5` gives a subtle glow effect.

---

### `[appearance]`

```toml
[appearance]
mode = "dark"    # "dark" | "light" | "auto"
```

---

### `[workspaceBar]`

The floating workspace indicator bar.

```toml
[workspaceBar]
enabled = true
position = "overlappingMenuBar"   # "overlappingMenuBar" (floats over menu bar) or reserve space
height = 24.0
notchAware = true                 # Avoid the MacBook Pro notch ✓
showLabels = true                 # Show workspace names/numbers
labelFontSize = 12.0
backgroundOpacity = 0.1           # 0.0 = fully transparent background
hideEmptyWorkspaces = false       # Hide workspaces with no windows
showFloatingWindows = false        # Include floating windows in bar display
deduplicateAppIcons = false        # Merge duplicate app icons in the bar
windowLevel = "popup"             # Z-level: "popup" sits above most windows
xOffset = 0.0                     # Horizontal nudge
yOffset = 0.0                     # Vertical nudge

[workspaceBar.accentColor]
alpha = 1.0
red = -1.0    # -1.0 = use system accent color
green = -1.0
blue = -1.0

[workspaceBar.textColor]
alpha = 1.0
red = -1.0
green = -1.0
blue = -1.0
```

---

### `[focus]`

Focus-follows-mouse and mouse warp behaviour.

```toml
[focus]
followsMouse = false             # Focus window under cursor automatically
followsWindowToMonitor = false   # Focus jumps to new monitor when window moves there
moveMouseToFocusedWindow = false # Cursor warps to the center of the focused window
```

---

### `[gestures]`

Trackpad swipe to scroll through columns.

```toml
[gestures]
scrollEnabled = true
fingerCount = 3                   # Number of fingers for the scroll gesture
invertDirection = true            # Match macOS natural scroll direction
scrollModifierKey = "optionShift" # Hold this key to activate scroll gesture
scrollSensitivity = 5.0           # Higher = faster scroll
```

---

### `[quakeTerminal]`

Drop-down terminal toggled with `Option+\``.

```toml
[quakeTerminal]
enabled = true
heightPercent = 50.0         # Height as % of screen
widthPercent = 50.0          # Width as % of screen
position = "center"          # "center" | "top" | "bottom" | "left" | "right"
monitorMode = "focusedWindow" # Which monitor: "focusedWindow" | "primary"
opacity = 1.0
autoHide = false             # Auto-hide when focus leaves the terminal
animationDuration = 0.2      # Slide-in animation speed (seconds)
useCustomFrame = false       # Use OmniWM's custom frameless window chrome
```

The terminal app used is whatever your quake terminal app rule is set to (Ghostty by default — `com.mitchellh.ghostty`).

---

### `[mouseWarp]`

Cursor warping when focus crosses monitor boundaries (multi-monitor only).

```toml
[mouseWarp]
axis = "horizontal"   # "horizontal" | "vertical" | "both"
margin = 1            # Pixels from edge that trigger the warp
monitorOrder = []     # Custom monitor ordering (empty = auto)
```

---

### `[clipboard]`

*(v0.4.9+)* Clipboard history accessible from the command palette.

```toml
[clipboard]
historyEnabled = false      # Enable clipboard history
maxItems = 200              # Max number of entries to keep
maxItemBytes = 8388608      # Max size per item (8 MB)
maxTotalBytes = 67108864    # Max total history size (64 MB)
```

Access clipboard history via the command palette (`Ctrl+Option+Space`).

---

### `[state]`

Internal UI state — managed by OmniWM, no need to hand-edit.

```toml
[state]
commandPaletteLastMode = "windows"
hiddenBarIsCollapsed = true
```

---

### `[statusBar]`

Controls what the macOS menu bar status item shows.

```toml
[statusBar]
showAppNames = false       # Show focused app name in menu bar
showWorkspaceName = false  # Show active workspace name in menu bar
useWorkspaceId = false     # Use workspace ID instead of name
```

---

### `[[appRules]]`

Per-app minimum size constraints and layout overrides. OmniWM uses these to prevent windows from being tiled smaller than they can handle.

```toml
[[appRules]]
bundleId = "com.mitchellh.ghostty"
id = "7876C9EF-437E-4D4F-9C27-B1B02F4AABCE"  # Internal UUID, leave as-is
minHeight = 48.0
minWidth = 90.0
```

**Common bundle IDs** (for adding new rules):

| App | Bundle ID |
|-----|-----------|
| Ghostty | `com.mitchellh.ghostty` |
| Zed | `dev.zed.Zed` |
| Google Chrome | `com.google.Chrome` |
| Safari | `com.apple.Safari` |
| Zen Browser | `app.zen-browser.zen` |
| Firefox | `org.mozilla.firefox` |
| Arc | `company.thebrowser.Browser` |
| Slack | `com.tinyspeck.slackmacgap` |
| Notion | `notion.id` |
| Obsidian | `md.obsidian` |
| Linear | `com.linear` |
| Figma | `com.figma.Desktop` |
| Todoist | `com.todoist.mac.Todoist` |
| Raycast | `com.raycast.macos` |
| Telegram | `ru.keepcoder.Telegram` |
| Signal | `org.whispersystems.signal-desktop` |
| OrbStack | `dev.kdrag0n.MacVirt` |
| VSCode Insiders | `com.microsoft.VSCodeInsiders` |
| Xcode | `com.apple.dt.Xcode` |
| Claude | `com.anthropic.claudefordesktop` |
| Spotify | `com.spotify.client` |
| Discord | `com.hnc.Discord` |
| Zoom | `us.zoom.xos` |
| iTerm2 | `com.googlecode.iterm2` |
| Outlook | `com.microsoft.Outlook` |
| Messages | `com.apple.MobileSMS` |

**Find any app's bundle ID:**
```bash
mdls -name kMDItemCFBundleIdentifier /Applications/AppName.app | awk '{print $3}' | tr -d '"'
```

---

### `[[hotkeys]]`

Each hotkey entry maps a keyboard binding to an action ID.

```toml
[[hotkeys]]
binding = "Option+Left Arrow"
id = "focus.left"
```

Use `"Unassigned"` to explicitly leave an action without a binding.

**Valid modifier key names:** `Option`, `Shift`, `Control`, `Command`
**Special keys:** `Left Arrow`, `Right Arrow`, `Up Arrow`, `Down Arrow`, `Return`, `Tab`, `Space`, `Home`, `End`, `Page Up`, `Page Down`, `` ` ``, `-`, `=`, `.`, `,`

---

### `[[workspaces]]`

```toml
[[workspaces]]
id = "AD36F001-C57E-41A5-AC1D-DF5249D007F0"  # UUID — do not change
name = "1"                                    # Raw name (used in hotkeys)
displayName = "Code"                          # Optional human-readable label shown in bar
layoutType = "niri"                           # Per-workspace layout override

[workspaces.monitorAssignment]
type = "main"       # "main" = primary/built-in | "secondary" = external monitor
```

> ⚠️ Workspaces assigned to `"secondary"` won't appear until an external monitor is connected.

---

## Hotkey Reference

### Current Bindings

> Navigation uses **vim-style hjkl** (not arrow keys) to avoid conflicts with cursor movement shortcuts in text editors.

| Action | Binding |
| Switch workspace 1–9 | `Option+1..9` |
| Move window to workspace 1–9 | `Option+Shift+1..9` |
| Focus left / right / up / down | `Option+h/j/k/l` |
| Move window | `Option+Shift+h/j/k/l` |
| Focus previous window | `Option+Tab` |
| Workspace back-and-forth | `Ctrl+Option+Tab` |
| Focus column 1–9 | `Ctrl+Option+1..9` |
| Focus first column | `Option+Home` |
| Focus last column | `Option+End` |
| Move column left / right | `Ctrl+Option+Shift+h/l` |
| Move window to workspace ↑/↓ | `Ctrl+Option+Shift+k/j` |
| Center column | `Option+C` |
| Float / unfloat focused window | `Ctrl+Option+W` |
| Column width −10% / +10% | `Option+-` / `Option+=` |
| Window height −10% / +10% | `Option+Shift+-` / `Option+Shift+=` |
| Expand column to available width | `Ctrl+Option+F` |
| Reset window height | `Ctrl+Option+R` |
| Move column to first / last | `Ctrl+Option+Home` / `Ctrl+Option+End` |
| Move column to workspace ↑/↓ | `Ctrl+Option+Shift+PgUp/PgDn` |
| Cycle column width forward | `Option+.` |
| Cycle column width backward | `Option+,` |
| Toggle fullscreen | `Option+Return` |
| Toggle column full-width | `Option+Shift+F` |
| Balance sizes | `Option+Shift+B` |
| Toggle tabbed column | `Option+T` |
| Focus monitor next | `Ctrl+Cmd+Tab` |
| Focus monitor last | `Ctrl+Cmd+\`` |
| Command palette | `Ctrl+Option+Space` |
| Open menu anywhere | `Ctrl+Option+M` |
| Raise all floating windows | `Option+Shift+R` |
| Quake terminal | `Option+\`` |
| Toggle layout (Niri/Dwindle) | `Option+Shift+L` |
| Toggle overview | `Option+Shift+O` |

### Available Actions (Unassigned — assign as needed)

| Action ID | Description |
|-----------|-------------|
| `focusWindowTop` | Focus top window in current column |
| `focusWindowBottom` | Focus bottom window in current column |
| `focusWindowInColumn.1-9` | Jump to Nth window in column |
| `focusWindowOrWorkspaceDown/Up` | Focus window or switch workspace |
| `centerColumn` | Center the focused column on screen |
| `centerVisibleColumns` | Center all visible columns |
| `moveWindowDown/Up` | Move window within its column |
| `moveWindowDownOrToWorkspaceDown` | Move window down or to next workspace |
| `consumeOrExpelWindowLeft/Right` | Pull a window into / push out of the current column |
| `consumeWindowIntoColumn` | Consume focused window into adjacent column |
| `expelWindowFromColumn` | Eject focused window from its column |
| `moveColumnToFirst/Last` | Jump column to start or end of workspace |
| `moveColumnToIndex.1-9` | Move column to specific index |
| `expandColumnToAvailableWidth` | Expand column to fill available space |
| `resetWindowHeight` | Reset window height to default |
| `setColumnWidth.decrease10Percent` | Shrink column width by 10% |
| `setColumnWidth.increase10Percent` | Grow column width by 10% |
| `setWindowHeight.decrease10Percent` | Shrink window height by 10% |
| `setWindowHeight.increase10Percent` | Grow window height by 10% |
| `cycleWindowWidthForward/Backward` | Cycle individual window width presets |
| `cycleWindowHeightForward/Backward` | Cycle individual window height presets |
| `toggleFocusedWindowFloating` | Float / tile the focused window |
| `assignFocusedWindowToScratchpad` | Send window to scratchpad |
| `toggleScratchpadWindow` | Show/hide scratchpad window |
| `rescueOffscreenWindows` | Pull off-screen windows back into view |
| `toggleWorkspaceBarVisibility` | Show/hide workspace bar |
| `toggleHiddenBar` | Show/hide the hidden bar surface |
| `switchWorkspace.next/previous` | Cycle workspaces |
| `toggleNativeFullscreen` | macOS native fullscreen |

---

## IPC & CLI (`omniwmctl`)

Full automation via Unix socket. Enable in settings: `ipcEnabled = true`.

**Install CLI to PATH** via the OmniWM status bar menu → "Install CLI to PATH".

### Essential commands

```bash
# Check connectivity
omniwmctl ping

# Focus / move
omniwmctl command focus left
omniwmctl command move right

# Switch workspace
omniwmctl command switch-workspace 3
omniwmctl command switch-workspace back-and-forth

# Query windows
omniwmctl query windows
omniwmctl query focused-window
omniwmctl query windows --workspace 2 --format table

# Column operations
omniwmctl command toggle-column-full-width
omniwmctl command cycle-column-width forward

# Window rules (add/remove/apply at runtime)
omniwmctl rule add --bundle-id com.apple.finder --layout float
omniwmctl rule add --bundle-id com.tinyspeck.slackmacgap --assign-to-workspace 4
omniwmctl rule apply  # re-apply to focused window

# Event subscriptions
omniwmctl subscribe focus
omniwmctl watch active-workspace --exec ./on-workspace-change.sh
omniwmctl subscribe --all

# Shell completions (add to ~/.zshrc)
eval "$(omniwmctl completion zsh)"
```

### Useful queries

```bash
omniwmctl query displays                       # Monitor info
omniwmctl query workspaces --format table      # All workspaces
omniwmctl query focused-window-decision        # Why was this window tiled/floated?
omniwmctl query capabilities                   # Full protocol feature list
```

---

## Float Rules Setup

Float rules (always-floating apps) **cannot live in `settings.toml`** — they are persisted by OmniWM's IPC layer separately. Run the setup script once after a fresh install or OmniWM state reset:

```bash
bash ~/dotfiles/omniwm/setup-rules.sh
```

The script is idempotent — it skips rules already set to `float`, and upgrades `auto` rules in-place preserving min-size constraints.

**Currently configured float apps:**

| App | Bundle ID |
|-----|-----------|
| Numi | `com.dmitrynikolaev.numi` |
| Todoist | `com.todoist.mac.Todoist` |

To add more float apps, edit the `ensure_float_rule` calls at the bottom of `omniwm/setup-rules.sh`.

Verify at any time:
```bash
omniwmctl query rules --format table
```

---

## Multi-Monitor Setup

Two working modes are configured:

### Mode 1 — MacBook only
Workspaces 1–5 on `main` (built-in display). Workspaces 6–7 (`secondary`) remain inactive.

### Mode 2 — Three-monitor desk
| Monitor | Position | Role | Workspaces |
|---------|----------|------|------------|
| 4K 27" | Center | **primary / `main`** | 1–5 |
| 1900px 27" | Left | **`secondary`** | 6 (❤️), 7 (🚀) |
| MacBook | Left-below external | **tertiary** | — (see below) |

Workspaces 1–5 follow whichever monitor is set as macOS primary — they'll land on the 4K in desk mode and the MacBook in solo mode automatically.

### Adding MacBook-as-tertiary workspaces

OmniWM supports pinning workspaces to a specific display by name via `type = "specificDisplay"`. To set this up:

1. Connect all monitors and launch OmniWM
2. Get your MacBook display name:
   ```bash
   omniwmctl query displays --format table
   ```
   Look for the built-in display (e.g. `"Built-in Retina Display"`).
3. Add workspaces to `settings.toml`:
   ```toml
   [[workspaces]]
   id = "<new-uuid>"
   name = "8"
   layoutType = "niri"

   [workspaces.monitorAssignment]
   type = "specificDisplay"
   output = { displayId = 1, name = "Built-in Retina Display" }
   ```
   Replace the `name` value from step 2. Generate a UUID with `python3 -c "import uuid; print(uuid.uuid4())"` .

> **Note:** `displayId` can change across reboots; OmniWM falls back to name-matching when the ID doesn't match, so the display name is what matters.

---

## Updating

```bash
# Check installed version
omniwmctl version

# Upgrade via Homebrew
brew upgrade barutsrb/tap/omniwm

# Check latest release on GitHub
gh release list --repo BarutSRB/OmniWM --limit 3
```

After updating, compare your `settings.toml` against the upstream canonical to pick up new config keys:
```
~/.cache/checkouts/github.com/BarutSRB/OmniWM/Tests/OmniWMTests/Fixtures/canonical-settings.toml
```

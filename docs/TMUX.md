# Tmux Guide

Prefix key: `Ctrl+A` (referred to as `prefix` below).

## The Setup

**Terminal:** Ghostty (tmux host, handles local tabs and splits)
**Editor:** Zed (editing only, its terminal for ephemeral one-offs)
**Tmux role:** Persistent project sessions locally. Full pane management remotely over SSH.
**AI coding:** Claude Code in a dedicated tmux window per project, plus `prefix + Ctrl+j` popup for ad-hoc questions.

### Prerequisites (macOS)

```bash
brew install tmux
brew install joshmedeski/sesh/sesh
brew install tmuxinator
```

## The Daily Flow

**Morning.** Open Ghostty. `tmux a` or let it auto-attach. Hit `prefix + Space`, fuzzy-find your first client project, you're in. `prefix + 2` to check the dev server. `prefix + 3` to see what Claude finished overnight.

**Switching projects.** Client B pings you. `prefix + Space`, type a few letters, enter. You're in that session. Window 1 is shell, window 2 is dev server, window 3 is Claude. Open Zed pointed at the repo. Work.

**Quick question about another project.** `prefix + Space` to switch sessions. `prefix + Ctrl+j` for a Claude popup, ask the question, dismiss.

**End of day.** Don't close anything. Quit Ghostty if you want, tmux server keeps running. Tomorrow morning, `tmux a` and you're exactly where you left off. Mac restart overnight: tmux-continuum restores sessions, dev servers are dead but window layouts, working directories, and Claude conversations are back. `up-arrow + enter` in the server windows to restart them.

## Session Management

Each client project lives in its own tmux session. A session typically has 3 windows: `shell`, `server`, `claude`. Devops-heavy projects add an `infra` window via a tmuxinator config.

```bash
# Create a new session
tmux new -s client-name

# Attach to existing
tmux attach -t client-name

# List sessions
tmux ls
```

| Keys               | Action                            |
| ------------------ | --------------------------------- |
| `prefix + Space`   | Fuzzy find sessions via sesh      |
| `prefix + S`       | Choose session from built-in list |
| `prefix + Ctrl+D`  | Detach from current session       |
| `prefix + Ctrl+X`  | Lock server                       |

Closing the last window in a session switches to another session instead of detaching.

### Per-project templates (tmuxinator)

For projects that need a specific window layout, create a tmuxinator config. Sesh auto-discovers these.

`~/.config/tmuxinator/acme.yml`:

```yaml
name: acme
root: ~/code/clients/acme

windows:
  - shell: ~/code/clients/acme
  - server:
      panes:
        - docker compose up
  - claude:
      panes:
        - claude
```

## Windows

Windows are numbered starting from 1.

| Keys              | Action                          |
| ----------------- | ------------------------------- |
| `prefix + 1..9`   | Jump to window by number        |
| `prefix + Tab`    | Toggle between last two windows |
| `prefix + Ctrl+A` | Toggle last window (alternate)  |
| `prefix + H`      | Previous window                 |
| `prefix + L`      | Next window                     |
| `prefix + Ctrl+C` | New window (current directory)  |
| `prefix + r`      | Rename current window           |
| `prefix + w`      | List all windows                |
| `prefix + "`      | Choose window                   |

## Panes

Locally, prefer Ghostty for splits. These bindings are mainly useful over SSH.

| Keys         | Action                            |
| ------------ | --------------------------------- |
| `prefix + s` | Split vertically (top/bottom)     |
| `prefix + v` | Split horizontally (side by side) |
| `prefix + h` | Move to left pane                 |
| `prefix + j` | Move to pane below                |
| `prefix + k` | Move to pane above                |
| `prefix + [` | Previous pane                     |
| `prefix + ]` | Next pane                         |
| `prefix + z` | Toggle pane zoom (fullscreen)     |
| `prefix + x` | Swap pane down                    |
| `prefix + c` | Kill current pane                 |
| `prefix + *` | Synchronize input to all panes    |
| `prefix + P` | Toggle pane border status         |

> **Note:** `prefix + l` is bound to `refresh-client` (see Misc), not pane-right. Use `prefix + ]` to cycle to the next pane instead.

### Resizing (repeatable)

| Keys         | Action         |
| ------------ | -------------- |
| `prefix + ,` | Shrink left 20 |
| `prefix + .` | Grow right 20  |
| `prefix + -` | Shrink down 7  |
| `prefix + =` | Grow up 7      |

## Copy Mode

Enter with `prefix + [`. Vi keys for navigation.

| Keys       | Action                                   |
| ---------- | ---------------------------------------- |
| `v`        | Begin selection                          |
| `y`        | Copy to clipboard (pbcopy)               |
| Mouse drag | Auto copies selection to clipboard       |
| Scroll     | Mouse wheel, `j`/`k`, `Ctrl+d`/`Ctrl+u` |

tmux-yank handles clipboard across platforms (pbcopy on macOS, xclip/xsel on Linux).

## Claude Code

| Keys              | Action                                           |
| ----------------- | ------------------------------------------------ |
| `prefix + Ctrl+j` | Claude popup (80x80%, current directory)         |
| `prefix + 3`      | Jump to Claude window (if using 3-window layout) |

The popup is for quick questions. For long running agent tasks, use a dedicated Claude window so it survives session switching. Long Claude runs survive detach, reboot, and SSH disconnects.

## Plugins

Managed by TPM at `~/.config/tmux/plugins/`.

| Keys             | Action                |
| ---------------- | --------------------- |
| `prefix + I`     | Install new plugins   |
| `prefix + U`     | Update plugins        |
| `prefix + alt+u` | Remove unused plugins |

### Installed

| Plugin          | Purpose                                                      |
| --------------- | ------------------------------------------------------------ |
| tmux-sensible   | Sane defaults                                                |
| tmux-yank       | Cross-platform clipboard                                     |
| tmux-resurrect  | Save/restore sessions (`prefix + Ctrl+s` / `Ctrl+r`); also restores nvim sessions |
| tmux-continuum  | Auto-save every 15 min, auto-restore on start                |
| tmux-thumbs     | Quick copy visible hashes, paths, IPs, URLs (`prefix + t`)  |
| tmux-fzf-url    | Extract and open URLs from scrollback (`prefix + u`)         |
| catppuccin-tmux | Status bar theme (omerxx fork)                               |

## Misc

| Keys              | Action              |
| ----------------- | ------------------- |
| `prefix + R`      | Reload tmux config  |
| `prefix + K`      | Clear terminal      |
| `prefix + Ctrl+L` | Refresh client      |
| `prefix + l`      | Refresh client      |
| `prefix + :`      | Command prompt      |

## Terminal Features

Uses `terminal-features` (tmux 3.2+) instead of `terminal-overrides`. Per-terminal declarations:

| Terminal        | Features                                          |
| --------------- | ------------------------------------------------- |
| xterm-ghostty   | RGB, hyperlinks, sixel, usstyle, clipboard        |
| xterm-256color  | RGB, usstyle                                      |
| alacritty       | RGB, usstyle                                      |
| tmux-256color   | RGB, usstyle                                      |

Additional settings:
- `extended-keys on` + `extended-keys-format csi-u` — CSI u encoding for modified keys (e.g. `Ctrl+Shift+…`)
- `allow-passthrough on` — OSC sequences pass through (images, hyperlinks, inline graphics)
- `focus-events on` — focus gain/loss events forwarded to applications

OSC52 (`set-clipboard on`) handles clipboard back to your Mac over SSH. No pbcopy needed on the server.

## Onboarding a New Server

```bash
git clone <dotfiles-url> ~/dotfiles
cd ~/dotfiles && stow tmux
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
tmux new -s work
# prefix + I to install plugins
```

## Status Bar

Catppuccin theme (omerxx fork). Session name on the left. Current directory basename and time (`HH:MM`) on the right. Current window is highlighted. Zoomed windows show `()` indicator.

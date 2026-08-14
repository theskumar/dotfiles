# Herdr Guide

Prefix key: `Ctrl+A` (same as tmux; this guide calls it `prefix`).

Herdr is a terminal workspace manager for AI coding agents (a tmux-like
multiplexer, but mouse-first and agent-aware). It is a **trial** that runs
alongside tmux, not a replacement. A background server owns the panes; clients
attach/detach. Workspaces = "spaces" (one per project); each holds tabs and
panes. The sidebar rolls up each agent's state (`working` / `blocked` / `done`).

## The Setup

**Terminal:** Ghostty (same host as tmux; `cmd+*` shortcuts send `prefix + key`).
**Multiplexer:** herdr in some Ghostty windows, tmux in others — never nested
(both grab `Ctrl+A`).
**AI coding:** pi / claude; herdr detects them automatically and shows state in the sidebar.
**Config:** stowed — `~/dotfiles/herdr/herdr/config.toml` → `~/.config/herdr/config.toml`.

### Prerequisites (macOS)

```bash
curl -fsSL https://herdr.dev/install.sh | sh   # or: brew / mise / nix
```

Version pinned in use: **0.8.0+** (navigator plugin needs ≥ 0.8.0; the socket
protocol and `type = "plugin_action"` bindings assume 0.8.0).

## Design: one prefix, shared with tmux

Ghostty translates every `cmd+*` shortcut into `Ctrl+A + <key>` text. Because
**herdr's prefix is also `Ctrl+A`**, the same Ghostty shortcuts drive *both*
tmux and herdr. herdr binds its actions to the chords tmux already uses.
**herdr never touches the tmux config**; it adopts.

| macOS key | Ghostty sends | herdr action | in tmux |
| --------- | ------------- | ------------ | ------- |
| `cmd+t`   | `Ctrl+A Ctrl+C` | new tab            | new window        |
| `cmd+w`   | `Ctrl+A c`      | close tab          | kill pane         |
| `cmd+b`   | `Ctrl+A b`      | toggle sidebar     | (unbound; herdr-only) |
| `cmd+p`   | `Ctrl+A Space`  | Navigator (find/create) | sesh picker  |
| `cmd+j`   | `Ctrl+A Ctrl+J` | lazygit popup      | lazygit popup     |
| `cmd+e`   | `Ctrl+A Ctrl+E` | open Zed at repo root | (unbound; herdr-only) |
| `cmd+x`   | `Ctrl+A Ctrl+H` | hx in a new side pane at repo root | hx in a new side pane at repo root |
| `cmd+s`   | `Ctrl+A Shift+S`| (unbound in herdr) | choose-session    |

`cmd+b` is the only Ghostty change for herdr (a herdr-only concept). All
others reuse existing tmux chords. `cmd+s` still runs tmux choose-session;
herdr does not map it on purpose.

## Keybindings (effective)

Custom (set in `config.toml`) plus the herdr defaults worth knowing:

| Keys              | Action                                   |
| ----------------- | ---------------------------------------- |
| `prefix + Ctrl+C` | New tab (`cmd+t`)                        |
| `prefix + c`      | Close focused pane (`cmd+w`); also `prefix+x` |
| `prefix + b`      | Toggle sidebar (`cmd+b`)                 |
| `prefix + Space`  | Navigator: find/create space (`cmd+p`)  |
| `prefix + Ctrl+J` | Lazygit popup at repo root (`cmd+j`)    |
| `prefix + Ctrl+E` | Open Zed at repo root, detached GUI (`cmd+e`) |
| `prefix + Ctrl+H` | Open hx (helix) in a new side pane at repo root (`cmd+x`) |
| `prefix + u`      | Herdr Pluck: hint-label a visible URL and open it |
| `prefix + t`      | Herdr Pluck: hint-label a visible token and copy it |
| `prefix + w`      | Native workspace switcher (open spaces) |
| `prefix + v` / `prefix + -` | Split right / down             |
| `prefix + h/j/k/l`| Focus pane left/down/up/right           |
| `prefix + z`      | Zoom pane                                |
| `prefix + n` / `prefix + p` | Next / previous tab            |
| `prefix + 1..9`   | Jump to tab                              |
| `prefix + Shift+N`| New workspace                            |
| `prefix + q`      | Detach (everything keeps running)        |
| `prefix + ?`      | List all live bindings                   |
| `prefix + Shift+R`| Reload config                            |

## Navigator plugin (`cmd+p`)

`cmd+p` opens **herdr-navigator**. It is a sesh-style fuzzy find-or-create
picker across workspaces, agents, projects, sessions, and zoxide directories.
I chose it because it runs on 0.7.3+, has active maintenance, and needs no
herdr update to try. It replaces the tmux `sesh` workflow *inside* herdr (sesh itself only
manages tmux sessions).

```bash
herdr plugin install thanhdat77/herdr-navigator --ref v0.3.5 --yes  # Rust; builds via cargo
herdr plugin list
herdr plugin action list --plugin herdr-navigator                    # action: herdr-navigator.open
```

Config dir: `~/.config/herdr/plugins/config/herdr-navigator` (tune project
roots, zoxide sources, ordering). A `jump-back` action exists (jump to last
space) — unbound for now.

## hx side pane (`prefix+ctrl+h`)

`cmd+x` opens **hx** (helix) in a new side-by-side pane at the repo root.
It does not zoom over or disturb the pane you were already in
(e.g. a running agent). `tmux` gets this natively via a plain `split-window`
bind. herdr cannot. Its `[[keys.command]] type = "pane"` (what the lazygit
binding uses) always zooms the new pane fullscreen. It also tears the pane
down as a temporary overlay when the command exits. There is no config flag
to turn that off. So the herdr side calls `bin/hx-split`, which drives the socket
API directly:

1. `herdr pane split --direction right --cwd <repo root> --focus` -- a real,
   non-zoomed split.
2. `herdr pane run <pane id> "hx . ; exit"` -- types the command in. The
   trailing `; exit` makes the pane's shell close the moment `hx` quits, so
   nothing lingers.

I verified this end-to-end with the socket API (`herdr pane get` on the
pane id returns `pane_not_found` right after you quit `hx`).

## Pluck plugin (`prefix+u` / `prefix+t`)

**herdr-pluck** hint-labels visible text in the pane (like `tmux-fzf-url` /
`tmux-thumbs`). You jump to it with a couple of keystrokes instead of the
mouse.

```bash
herdr plugin install rmarganti/herdr-pluck --yes
herdr plugin action list --plugin herdr-pluck
```

- `prefix+u` → `rmarganti.herdr-pluck.open-url`: label every visible URL, open the chosen one.
- `prefix+t` → `rmarganti.herdr-pluck.pluck`: label visible tokens (paths, hashes, IPs, etc.), copy the chosen one.

## Config

- Edit the **dotfiles** source, not the symlink: `~/dotfiles/herdr/herdr/config.toml`.
- Apply to the live server: `herdr server reload-config` (or `prefix + Shift+R`).
- `herdr --default-config` prints the full annotated defaults.
- **Herdr writes to this file itself** (e.g. `onboarding = false`, and UI-toggled
  keys like `show_agent_labels_on_pane_borders`). Those appear as diffs in
  dotfiles — commit them; they are real state.
- Theme is `catppuccin` (matches tmux); `resume_agents_on_restore = true`.
- `[ui.toast] delivery = "system"` routes herdr toasts (e.g. agent state
  changes) through native macOS notifications instead of in-app-only toasts.

## Integrations

Give herdr authoritative agent state instead of a screen scrape:

```bash
herdr integration status
herdr integration install <agent>   # pi / claude / hermes already current
```

## Gotchas (read before automating)

- **`HERDR_ENV=1`** means you are inside a herdr pane. Never run bare `herdr`
  nested; herdr blocks the launch by design.
- **`herdr update` cannot run inside herdr.** Detach / `herdr server stop`
  first, update in a plain terminal, then reattach:
  ```bash
  herdr server stop && herdr update && herdr
  ```
- **Do not nest tmux inside a herdr pane** — both use `Ctrl+A`; herdr wins and
  tmux never sees the prefix. Use one per terminal.
- Prefer the **CLI over raw keys** for scripts: `herdr workspace|tab|pane|agent
  <sub>` all speak the socket API. `herdr api schema --json` documents it.
- Logs: `~/.config/herdr/herdr{,-server,-client}.log`. Runtime: `herdr status`.
- **`prefix+s` always belongs to the built-in `settings` action.** herdr
  resolves key conflicts in struct-declaration order. herdr declares
  `settings` long before `split_horizontal`. So herdr silently disables any
  bind of `split_horizontal` (or anything else) to `prefix+s` (check
  `herdr-server.log` for `config diagnostic ... kept keys.settings, disabled
  ...`). Use `split_horizontal`'s actual default, `prefix+minus`, instead.
  That is what ghostty's `cmd+shift+d` sends.
- **The last pane/tab in a space closes the space.** Both `close_pane`
  and `close_tab` cascade to `close_workspace` once nothing remains
  (`app/actions.rs`) — exact tmux parity (the last window closes the session).
  The config binds `cmd+w` to `close_pane` (not `close_tab`) so splits
  survive it. `cmd+w` cascades to close the space only when it is truly the
  last pane in the last tab. For a typical one-tab-one-pane space, that is
  still every time. `confirm_close` does **not** guard this path (it only
  guards a linked worktree group). So there is no config-level way to get a
  confirmation prompt here. Open a second pane/tab in a space if you want
  `cmd+w` to stay non-destructive.

## Onboarding a new machine

```bash
git clone <dotfiles-url> ~/dotfiles
cd ~/dotfiles && ./install.sh                 # stows herdr (in the XDG set)
curl -fsSL https://herdr.dev/install.sh | sh  # herdr >= 0.8.0
herdr plugin install thanhdat77/herdr-navigator --ref v0.3.5 --yes
herdr plugin install rmarganti/herdr-pluck --yes
herdr integration install pi                  # + claude, hermes as needed
cd ~/some/project && herdr                     # attach; agent shows in sidebar
```

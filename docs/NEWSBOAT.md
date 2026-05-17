# Newsboat Configuration Guide

> **Config:** `newsboat/newsboat/` → stowed to `~/.config/newsboat/`
> **Installed:** `brew install newsboat` via `setup/setup_mac.sh`
> **Version:** 2.43+ (Homebrew)

Newsboat is a terminal RSS/Atom feed reader. This setup is local-only (no sync), macOS-focused, with a cowork-kb bookmark integration and clean in-terminal reading via Mozilla Readability.

---

## Table of Contents

- [Installation](#installation)
- [File Structure](#file-structure)
- [Macros](#macros)
- [Adding Feeds](#adding-feeds)
- [Saving to cowork-kb](#saving-to-cowork-kb)
- [Substack Feeds](#substack-feeds)
- [YouTube Feeds](#youtube-feeds)
- [Color Scheme](#color-scheme)
- [Useful Aliases](#useful-aliases)
- [Pruning Dead Feeds](#pruning-dead-feeds)
- [Key Bindings](#key-bindings)

---

## Installation

```bash
# Install newsboat and readability-cli (already in setup/setup_mac.sh)
brew install newsboat
npm install -g readability-cli

# Stow the config (already in install.sh XDG array)
stow --target="$HOME/.config" newsboat
```

---

## File Structure

```
newsboat/newsboat/               ← stowed to ~/.config/newsboat/
├── config                       ← main settings, macros, key bindings
├── urls                         ← feed list with tags
├── colorschemes/
│   └── nord                     ← nord colour scheme (from newsboat contrib)
└── scripts/
    ├── bookmark-kb.sh           ← save article to cowork-kb/raw/clips/
    ├── fltr-substack.sh         ← strip Substack subscription nags
    └── newsboat-idlefeeds.sh    ← list feeds idle > 6 months
```

Runtime files (not tracked in dotfiles):
```
~/.local/share/newsboat/
├── cache.db                     ← SQLite: articles, read/unread state
└── queue                        ← podboat download queue
```

---

## Macros

Macros are triggered with `,` followed by the key. In the article list or article view:

| Keys | Action |
|---|---|
| `,o` | Open article in default browser (`open %u`) |
| `,r` | Fetch **full article** from source URL (`readable` + `glow`) — for truncated feeds |
| `,y` | Play video/audio in `mpv` (YouTube, podcasts) |
| `,b` | Save article silently to `cowork-kb/raw/clips/` |

> **Default article view** (`Enter` / `l`): feed HTML → markdown via `pandoc` → rendered by `glow`. The `,r` macro is for truncated feeds where you want the full text fetched from the source URL.

---

## Adding Feeds

Edit `~/.config/newsboat/urls` (symlinked from dotfiles):

```
# Plain feed with tags
https://example.com/feed    tech python

# Rename feed in UI (prefix tag with ~)
https://example.com/feed    tech "~Custom Name"

# Tag only (hidden from main list, used in query feeds)
https://example.com/feed    tech !
```

After editing, reload in newsboat with `R` (reload all) or `r` (reload current).

### GitHub Release Feeds

Track releases for any GitHub repo:
```
https://github.com/<owner>/<repo>/releases.atom    releases
```

---

## Saving to cowork-kb

Hit `,b` on any article. The script (`scripts/bookmark-kb.sh`):

1. Extracts clean article text via `readable` (Mozilla Readability)
2. Generates a slug from the article title
3. Saves to `~/Documents/cowork-kb/raw/clips/YYYY-MM-DD-<slug>.md`
4. Adds frontmatter: `title`, `url`, `saved`, `source: newsboat`
5. Shows a macOS notification on success

Claude can then ingest it from `raw/clips/` the same way it handles Obsidian Web Clipper clips.

---

## Substack Feeds

The `fltr-substack.sh` script strips the subscription nag injected into Substack article content. Wrap any Substack feed in `urls`:

```
filter:~/.config/newsboat/scripts/fltr-substack.sh:https://example.substack.com/feed   newsletters
```

---

## YouTube Feeds

YouTube exposes RSS feeds per channel. Find the channel ID from the channel URL, then:

```
https://www.youtube.com/feeds/videos.xml?channel_id=<CHANNEL_ID>   youtube
```

Open with `,y` to stream directly in `mpv` without opening a browser.

---

## Color Scheme

Uses **nord** from the official newsboat contrib, loaded via:
```ini
include "~/.config/newsboat/colorschemes/nord"
```

Other bundled schemes (swap in `config` if desired): `gruvbox`, `solarized-dark`, `solarized-light`, `monochrome`.
To use another, copy it to `colorschemes/` and update the `include` line.

---

## Useful Aliases

Defined in `shell/.aliases`:

| Alias | Command |
|---|---|
| `nb` | `newsboat` — launch newsboat |
| `nb-idle` | `~/.config/newsboat/scripts/newsboat-idlefeeds.sh` — list idle feeds |

---

## Pruning Dead Feeds

Run `nb-idle` to list feeds that haven't published in 6+ months:

```bash
nb-idle               # default: 6 months
nb-idle -t '1 year'   # custom threshold
```

Then remove the dead URLs from `~/.config/newsboat/urls`.

---

## Key Bindings

Vim-style bindings configured in `config`:

| Key | Action |
|---|---|
| `j` / `k` | Down / up |
| `J` / `K` | Next / previous feed |
| `g` / `G` | Top / bottom |
| `d` / `u` | Page down / up |
| `l` | Open feed or article |
| `h` | Go back / quit |
| `r` | Reload current feed |
| `R` | Reload all feeds |
| `n` / `N` | Next / previous unread |
| `q` | Quit |

---

## Auto-reload

Configured to reload all feeds every **60 minutes** with **50 parallel threads**:
```ini
auto-reload yes
reload-time 60
reload-threads 50
```

No cron job needed — newsboat handles this internally while running.

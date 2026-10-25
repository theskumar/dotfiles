# Keychron K8 Pro and MacBook keyboard

This page covers the layout in `docs/keychron-k8-pro.layout.json` and the matching Karabiner rules in `karabiner/karabiner/karabiner.json`. The setup targets the macOS stack in these dotfiles: Karabiner, OmniWM, Ghostty with tmux, Zed, Helix, Wispr Flow, and WriteText.

Each Keychron feature has the same key position on the MacBook Pro built-in keyboard. The Keychron firmware does part of the work. Karabiner does the rest for both keyboards.

## Key map: Keychron and MacBook

| Action | Keychron K8 Pro | MacBook built-in |
|---|---|---|
| Esc (tap) or Ctrl (hold) | Caps Lock | Caps Lock |
| Fn layer (nav, macros) | Hold Left Ctrl or Fn | Hold Left Control |
| Wispr hands-free on or off | Tap the Siri key | Tap Globe |
| Wispr push to talk | Hold the Siri key | Hold Globe |
| Wispr hands-free, left hand | Left Ctrl+Space | Left Control+Space |
| WriteText macro | Screenshot key, or Left Ctrl+R | Left Control+R |
| OmniWM command palette | Insert | Ctrl+Opt+Space |
| OmniWM overview | Left Ctrl+Insert | Opt+Shift+O |
| Screenshot | Left Ctrl+Screenshot key | Cmd+Shift+4 |

The middle mouse button also toggles Wispr hands-free.

## Load the layout

1. Open [Keychron Launcher](https://launcher.keychron.com) or VIA and connect the keyboard by cable.
2. Back up the current layout with **Save**.
3. Load `docs/keychron-k8-pro.layout.json`.

If the editor rejects the macro delays such as `{300}`, update the firmware in Keychron Launcher.

Keep the Mac/Win switch on Mac. Layer 0 is the Mac base layer. Layer 1 is the Fn layer. Layers 2 and 3 are the stock Windows layers and stay unchanged.

## Layer 0: base changes

| Key | Stock | New | Purpose |
|---|---|---|---|
| Left Ctrl | Ctrl | `MO(1)` | Fn layer for the left hand. Caps Lock is Ctrl through Karabiner. |
| Screenshot key | Cmd+Shift+4 | `MACRO(4)` | Select all, copy, open WriteText, then press Cmd+Enter |
| Siri key | Siri | `KC_F18` | Wispr key. Karabiner handles tap and hold. |
| Insert | Insert | `LCA(KC_SPC)` | OmniWM command palette (Ctrl+Opt+Space) |

The other keys keep their stock behavior.

## Layer 1: hold Left Ctrl or Fn

The MacBook Left Control layer in Karabiner has the same keys, except Insert and the Screenshot key.

| Key | Output | Tool |
|---|---|---|
| H J K L | Arrow keys | All apps |
| U / D | Page Up / Page Down | All apps |
| Backspace | Opt+Backspace | Delete the previous word |
| Arrow keys | Opt+Shift+Arrow | OmniWM: move the window |
| Space | Right Option | Wispr Flow hands-free on or off |
| V | Ctrl+Cmd+V | Wispr Flow: paste the last transcript |
| C | Ctrl+Cmd+C | Wispr Flow: copy the last transcript |
| O | Macro 0 | Ghostty, then the sesh picker |
| G | Macro 1 | Ghostty, then the lazygit popup |
| T | Macro 2 | Ghostty, then a new tmux window that runs `pi` |
| P | Macro 3 | Select all, then Writing Tools Proofread |
| R | Macro 4 | Select all, copy, open WriteText, then press Cmd+Enter |
| Insert | Opt+Shift+O | OmniWM overview (Keychron only) |
| Screenshot key | Cmd+Shift+4 | Screenshot (Keychron only) |

Stock Fn keys still work on the Keychron: F1 to F12, Fn+1/2/3 for Bluetooth hosts, Fn+Tab/Q/W/S for the backlight, and Fn+B for the battery level.

## Wispr Flow

Karabiner rule "Wispr key" turns one key into two actions:

- A tap shorter than 250 ms sends Right Option. Wispr binds Right Option to Hands-free.
- A hold longer than 250 ms sends Fn until you release the key. Wispr binds Fn to Push to talk, which is the Wispr default.

The Keychron Siri key sends F18 into this rule. On the MacBook, the Globe key goes through the same rule.

Set these bindings in Wispr Flow under **Settings → General → Shortcuts → Change**:

1. Push to talk: click **Reset to default**, or hold Globe for one second and release it. The binding reads Fn.
2. Hands-free mode: keep Middle Click.
3. Hands-free mode: click **+**, then tap the Siri key or Globe. The binding reads Right Option.

Wispr saves shortcuts per device. Repeat these steps on each Mac.

Set **System Settings → Keyboard → Press 🌐 key to** to **Do Nothing**. Otherwise a push-to-talk release can open the emoji picker.

To use Wispr Lens (Ctrl+Fn), hold Caps Lock, then hold the Siri key or Globe.

## Macros

| Slot | Sequence | Depends on |
|---|---|---|
| 0 | `{KC_LALT,KC_I}{300}{KC_LGUI,KC_P}` | Karabiner Opt+I opens Ghostty. Ghostty Cmd+P sends `C-a Space`. |
| 1 | `{KC_LALT,KC_I}{300}{KC_LGUI,KC_J}` | Ghostty Cmd+J sends `C-a C-j`. |
| 2 | `{KC_LALT,KC_I}{300}{KC_LCTL,KC_A}{KC_LCTL,KC_P}` | tmux `bind C-p` |
| 3 | `{KC_LGUI,KC_A}{50}{KC_LCTL,KC_LSFT,KC_P}` | `setup/osx_defaults.sh` Proofread hotkey |
| 4 | `{KC_LGUI,KC_A}{50}{KC_LGUI,KC_C}{100}{KC_LCTL,KC_LSFT,KC_Z}{400}{KC_LGUI,KC_ENT}` | WriteText hotkey Ctrl+Shift+Z. Cmd+Enter runs it. |

Slots 5 to 15 are free. Use macros for sequences that cross apps. Keep text snippets in Zed snippets.

The MacBook versions live in the Karabiner rule "MacBook Left Control = Keychron Fn layer". They use `shell_command` to activate Ghostty and `to_delayed_action` for the pauses. If you change a macro, change both places.

## Karabiner rules

| Rule | Keyboards |
|---|---|
| Caps Lock: tap Esc, hold Ctrl | All |
| Wispr key: tap = hands-free, hold = push to talk | Keychron (F18) and MacBook (Globe) |
| MacBook Left Control = Keychron Fn layer | MacBook only |
| App Launcher: Opt+B/S/N/L/E/I/O | All |

`~/.config/karabiner/karabiner.json` is a symlink into this repo. Karabiner does not detect edits to the symlink target. After you edit the file, run `touch -h ~/.config/karabiner/karabiner.json` to make Karabiner reload it.

Caps Lock stays in Karabiner, not in the firmware. Karabiner holds Ctrl at once, so a fast `Ctrl+A` for tmux works. A firmware mod-tap can send Esc and `a` instead.

Without Karabiner, for example on another computer over Bluetooth, the Siri key sends F18 and does nothing.

## Known conflicts

- Holding Globe on the MacBook for Fn shortcuts, such as Fn+Left for Home, also starts push to talk after 250 ms. Wispr cancels dictation when you press the second key.

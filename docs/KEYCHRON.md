# Keychron K8 Pro and MacBook keyboard

This page covers the layout in `docs/keychron-k8-pro.layout.json` and the matching Karabiner rules in `karabiner/karabiner/karabiner.json`. The setup targets the macOS stack in these dotfiles: Karabiner, OmniWM, Ghostty with tmux, Zed, Helix, Wispr Flow, and WriteText.

Both keyboards use the same key positions. Karabiner does most of the work, so the same rules apply to the Keychron and to the MacBook Pro built-in keyboard.

## Key map: Keychron and MacBook

| Action | Keychron K8 Pro | MacBook built-in |
|---|---|---|
| Esc (tap) or Ctrl (hold) | Caps Lock | Caps Lock |
| Hyper (Cmd+Ctrl+Opt+Shift) | Left Ctrl | Left Control |
| Wispr hands-free on or off | Tap the Siri key | Tap Globe |
| Wispr push to talk | Hold the Siri key | Hold Globe |
| WriteText macro | Screenshot key, or Hyper+R | Hyper+R |
| OmniWM command palette | Insert | Ctrl+Opt+Space |
| OmniWM overview | Fn+Insert | Opt+Shift+O |
| Screenshot | Fn+Screenshot key | Cmd+Shift+4 |

The middle mouse button also toggles Wispr hands-free.

## Hyper shortcuts

Hold Left Ctrl, then press the key. Hyper keys work the same on both keyboards.

| Key | Output | Tool |
|---|---|---|
| H J K L | Arrow keys | All apps |
| U / D | Page Up / Page Down | All apps |
| Backspace | Opt+Backspace | Delete the previous word |
| Arrow keys | Opt+Shift+Arrow | OmniWM: move the window |
| Space | Right Option | Wispr Flow hands-free on or off |
| V | Ctrl+Cmd+V | Wispr Flow: paste the last transcript |
| C | Ctrl+Cmd+C | Wispr Flow: copy the last transcript |
| G | Ghostty, then Cmd+J | lazygit popup |
| T | Ghostty, then `C-a C-p` | New tmux window that runs `pi` |
| P | Cmd+A, then Ctrl+Shift+P | Writing Tools Proofread |
| R | Cmd+A, Cmd+C, Ctrl+Shift+Z, then Cmd+Enter | WriteText |
| B | Open Zen Browser | App launcher |
| S | Open Slack | App launcher |
| N | Open Notion | App launcher |
| I | Open Ghostty | App launcher |
| E | Open Zed | App launcher |

Other Hyper+key combinations pass through unchanged. Use them for new shortcuts in any app.

Hyper includes Shift, so Shift+Hyper+H cannot select text. Use Shift with the arrow keys instead.

Do not bind Hyper+Period. macOS uses it to start a system diagnostic.

## Load the layout

1. Open [Keychron Launcher](https://launcher.keychron.com) or VIA and connect the keyboard by cable.
2. Back up the current layout with **Save**.
3. Load `docs/keychron-k8-pro.layout.json`.

If the editor rejects the macro delays such as `{50}`, update the firmware in Keychron Launcher.

Keep the Mac/Win switch on Mac. Layer 0 is the Mac base layer. Layer 1 is the Fn layer. Layers 2 and 3 are the stock Windows layers and stay unchanged.

## Firmware changes

| Layer | Key | Stock | New | Purpose |
|---|---|---|---|---|
| 0 | Siri key | Siri | `KC_F18` | Wispr key. Karabiner handles tap and hold. |
| 0 | Insert | Insert | `LCA(KC_SPC)` | OmniWM command palette (Ctrl+Opt+Space) |
| 0 | Screenshot key | Cmd+Shift+4 | `MACRO(4)` | Select all, copy, open WriteText, then press Cmd+Enter |
| 1 | Insert | Transparent | `LSA(KC_O)` | OmniWM overview |
| 1 | Screenshot key | Transparent | `CUSTOM(8)` | Stock screenshot |

Left Ctrl stays a plain Ctrl key in the firmware. Karabiner turns it into Hyper.

Macro 4:

```
{KC_LGUI,KC_A}{50}{KC_LGUI,KC_C}{100}{KC_LCTL,KC_LSFT,KC_Z}{400}{KC_LGUI,KC_ENT}
```

WriteText opens with its global hotkey Ctrl+Shift+Z. If you change that hotkey in WriteText, update macro 4 and the Hyper+R rule.

Do not press Left Ctrl with Insert or the Screenshot key. Left Ctrl+Insert sends Hyper+Space and toggles Wispr hands-free.

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

## Karabiner rules

| Rule | Keyboards |
|---|---|
| Caps Lock: tap Esc, hold Ctrl | All |
| Wispr key: tap = hands-free, hold = push to talk | Keychron (F18) and MacBook (Globe) |
| Left Control = Hyper | All |
| Hyper shortcuts: nav, Wispr, macros, apps | All |

`~/.config/karabiner/karabiner.json` is a symlink into this repo. Karabiner does not detect edits to the symlink target. After you edit the file, run `touch -h ~/.config/karabiner/karabiner.json` to make Karabiner reload it.

Caps Lock stays in Karabiner, not in the firmware. Karabiner holds Ctrl at once, so a fast `Ctrl+A` for tmux works. A firmware mod-tap can send Esc and `a` instead.

OmniWM has its own Hyper setting, `systemHyperTrigger` in `omniwm/omniwm/settings.toml`. Keep it at `None` so it does not compete with Karabiner.

Without Karabiner, for example on another computer over Bluetooth, the Siri key sends F18 and does nothing, and Left Ctrl is a plain Ctrl key.

## Known conflicts

- Holding Globe on the MacBook for Fn shortcuts, such as Fn+Left for Home, also starts push to talk after 250 ms. Wispr cancels dictation when you press the second key.

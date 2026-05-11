# Zsh Configuration: Optimization Log & Open Items

Living document tracking startup-perf and correctness work on `zsh/.zshrc` and
supporting files (`zsh/.zshenv`, `shell/.profile`, `zsh/.zsh/lib/completions.zsh`).

Benchmark cold start with:

```zsh
for i in {1..5}; do time zsh -i -c exit; done
```

Profile in-shell with:

```zsh
zmodload zsh/zprof    # uncomment line 1 of .zshrc
exec zsh
zprof
```

---

## ✅ Applied

| Change | Commit | Notes |
| --- | --- | --- |
| Remove duplicate `source ~/.profile` | `9413d13` | One source path through `.zshenv`/`.zshrc`. |
| `zcompile .zcompdump` + fixed cache check | `8344221` | ~30–80 ms. |
| Strengthen history settings | `bab9172` | `HISTFILE`, sharing, timestamps, dedup. |
| Defer compdef calls until turbo `compinit` | `d064e9b` | Shim queues pre-compinit `compdef`s, replayed in `atinit`. |
| Move PATH setup to `.zshenv` | `a828df7` | `typeset -U path PATH`; non-interactive shells see it. |
| Add navigation / globbing setopts | `b6ac092` | `AUTO_CD`, `AUTO_PUSHD`, `EXTENDED_GLOB`, etc. |
| Clean up duplicate / dead completion zstyles | `5f5dd8d` | Dropped `_approximate`, fixed `$ZSH` cache path, deduped `matcher-list`/`menu`. |
| Group `.zshrc` into labeled sections | `dab2603` | 1-Options, 2-PATH, 3-fpath, 4-Plugins, 5-compinit, 6-Keybindings, 7-Tools, 8-Prompt. |
| Drop `fnm` (mise replaces it) | `7e9736f` | Saves ~30–80 ms. |
| `mise activate --shims` mode | (in `7e9736f`) | No precmd hook; ~17 ms shell startup vs. ~10–30 ms per shim invocation. |
| Drop `OMZP::git`, inline used aliases | `76beb88` | Eliminated alias-clobber after first prompt; one less network/IO dep. |
| Track global `mise` config via stow | `e90bab6` | Reproducible toolchain across machines. |
| Avoid 5 `brew --prefix` forks at startup | `a084558` | Hardcoded `$HOMEBREW_PREFIX/opt` lookup; ~180 ms. |

---

## 🔴 Open items

### 1. Cache the remaining eager `eval`s

Three tools still fork at every shell start:

```zsh
eval "$(uv generate-shell-completion zsh)"   # ~20–50 ms
eval "$(zoxide init zsh --cmd j)"            # ~10–20 ms
eval "$(command wt config shell init zsh)"   # unknown
```

Pattern:

```zsh
_cache_eval() {
  local name=$1; shift
  local cache=~/.zsh/cache/$name.zsh
  [[ -s $cache && $cache -nt ${commands[$1]:-/dev/null} ]] \
    || { mkdir -p ~/.zsh/cache; "$@" > $cache; }
  source $cache
}
_cache_eval uv     uv generate-shell-completion zsh
_cache_eval zoxide zoxide init zsh --cmd j
command -v wt >/dev/null && _cache_eval wt wt config shell init zsh
```

Cache invalidates automatically when the binary is newer than the cache file
(version bumps via brew/mise will trigger regeneration). Expected savings:
~50–100 ms.

Keep `starship init zsh` eager — it's needed for the prompt and is already fast.

### 2. Address the `# fixme` in `completions.zsh`

`zsh/.zsh/lib/completions.zsh` opens with:

```zsh
# fixme - the load process here seems a bit bizarre
```

The file mixes setopts, `WORDCHARS`, `bindkey`, host-completion data harvesting,
and zstyles in one place. Split:

- shell behavior (`setopt`, `WORDCHARS`, `bindkey`) → top of `.zshrc` §1
- host completion list building → its own helper, only if SSH completion is used
- zstyles → stay here, renamed to e.g. `completion-styles.zsh`

This is maintainability, not perf — defer until something concretely breaks.

### 3. (Optional) Profile after item 1

Re-run the benchmark; if `_cache_eval` shaves the expected ~50–100 ms,
total cold start should be in the 150–300 ms range on Apple Silicon.

---

## Reference: file responsibilities

| File | Sourced for | Purpose |
| --- | --- | --- |
| `~/.zshenv` | all zsh (incl. scripts, cron) | env vars + PATH only |
| `~/.zprofile` | login shells | not used here |
| `~/.zshrc` | interactive shells | plugins, prompt, completion, keybindings |
| `~/.profile` (via `.zshrc`) | interactive shells | loads `~/.{exports,aliases,functions,extra}` + OS-specific |

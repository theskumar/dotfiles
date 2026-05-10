# Zsh Configuration Review & Optimization Suggestions

Review of `zsh/.zshrc` and supporting files (`shell/.profile`, `zsh/.zsh/lib/completions.zsh`).
Focus areas: **startup performance**, **correctness**, **maintainability**.

---

### 2. `compinit` is called before plugins that need to register completers

`zinit` plugins like `zsh-completions` use `zinit ice blockf` and need `compinit` to run **after** they’re loaded. Your order looks correct, but the cache check has an issue:

```zsh
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit -i        # cache > 24h: full check
else
  compinit -C -i     # otherwise: skip security check (fast path)
fi
```

The logic is **inverted**. The glob `(#qN.mh+24)` matches files older than 24 hours. If matched (cache stale), you should regenerate; if not matched (fresh), you should fast-path. Currently the slow path runs only when the dump is stale, which is correct — but the comment is misleading and `-i` is redundant on the `-C` path. More importantly, also add the `.zwc` compile step:

```zsh
autoload -Uz compinit
zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ -n "$zcompdump"(#qN.mh+24) ]]; then
  compinit -d "$zcompdump"
else
  compinit -C -d "$zcompdump"
fi
# Compile the dump for faster loads
[[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]] && zcompile "$zcompdump"
```

Compiling `.zcompdump` typically saves 30–80ms on startup.

---

### 3. Use Zinit's `wait` ice for lazy loading

The biggest startup win. Plugins like syntax-highlighting, autosuggestions, history-substring-search, completions, forgit, and the OMZ `git` snippet are not needed for the first prompt. Defer them:

```zsh
zinit wait lucid light-mode for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    zsh-users/zsh-history-substring-search \
    wfxr/forgit

zinit wait lucid for \
    OMZP::git
```

Using the `atinit"...zicompinit; zicdreplay"` trick lets Zinit handle compinit itself, replacing the manual block in #2. Expect 100–300ms shaved off startup.

---

### 4. Defer slow `eval` initializations

Each `eval "$(tool init)"` runs the tool synchronously at shell start. Stack them with Zinit's turbo mode or cache them:

| Tool                               | Current cost | Optimization                                         |
| ---------------------------------- | ------------ | ---------------------------------------------------- |
| `starship init zsh`                | ~10–30ms     | Acceptable (needed for prompt) — keep eager.         |
| `uv generate-shell-completion zsh` | ~20–50ms     | Cache to file like you do for kubectl.               |
| `zoxide init zsh --cmd j`          | ~10–20ms     | Cache or `zinit wait`.                               |
| `fnm env`                          | ~30–80ms     | Cache or replace with `mise` (you already use mise). |
| `mise activate zsh`                | ~30–60ms     | Cache or use `mise activate --shims` mode.           |
| `wt config shell init zsh`         | unknown      | `zinit wait` it.                                     |

Pattern for caching:

```zsh
_cache_eval() {
  local name=$1; shift
  local cache=~/.zsh/cache/$name.zsh
  [[ -s $cache && $cache -nt ${commands[$1]:-/dev/null} ]] || { mkdir -p ~/.zsh/cache; "$@" > $cache; }
  source $cache
}
_cache_eval zoxide zoxide init zsh --cmd j
_cache_eval uv    uv generate-shell-completion zsh
_cache_eval mise  mise activate zsh
```

---

### 5. `fnm` and `mise` both active — pick one

You install both `fnm` and `mise`. `mise` already manages Node. Running `fnm env` in addition is redundant and wastes ~30–80ms. Drop the fnm block:

```diff
- # fnm
- FNM_PATH="/opt/homebrew/opt/fnm/bin"
- if [ -d "$FNM_PATH" ]; then
-   eval "`fnm env`"
- fi
```

---

## 🟡 Medium Impact

### 6. History settings are weak

You set `HISTSIZE`/`SAVEHIST` but no `HISTFILE`, no sharing, no timestamps:

```zsh
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY        # timestamps
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE       # ignore commands starting with space
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY             # don't auto-execute !! expansions
setopt SHARE_HISTORY           # share across sessions
setopt INC_APPEND_HISTORY      # write immediately
```

---

### 7. PATH manipulation belongs in `.zshenv` / `.exports`

`PATH="$PATH:/Users/theskumar/.local/bin"` and the PNPM block are in `.zshrc`, meaning non-interactive shells (cron, scripts via `zsh -c`) won't see them. Move to `~/.exports` (already loaded in `.profile`) or a `.zshenv`. Also use `typeset -U path` to dedupe automatically:

```zsh
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$PNPM_HOME"
  "/opt/homebrew/opt/fnm/bin"
  $path
)
```

The hardcoded `/Users/theskumar/...` paths break portability — use `$HOME`.

---

### 8. kubectl completion cache logic is awkward

The date arithmetic works but is hard to read. Use the same glob qualifier trick as compinit:

```zsh
if command -v kubectl &>/dev/null; then
  local kc=~/.zsh/cache/_kubectl
  if [[ ! -f $kc || -n $kc(#qN.mh+24) ]]; then
    mkdir -p ~/.zsh/cache && kubectl completion zsh > $kc
  fi
  source $kc
fi
```

Better: drop the manual sourcing and let `compinit` find it by adding `~/.zsh/cache` to `fpath` **before** `compinit`:

```zsh
fpath=(~/.zsh/completions ~/.zsh/cache $fpath)
```

Then ensure the file is named `_kubectl` (it is). Only run regeneration; let compinit lazy-load.

---

### 9. Missing useful `setopt`s

```zsh
setopt AUTO_CD                 # `cd foo` → just type `foo`
setopt AUTO_PUSHD              # `cd` pushes to dir stack
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS    # allow `# comments` in interactive shell
setopt NO_BEEP
setopt CORRECT                 # offer typo correction (optional)
```

---

### 10. `completions.zsh` has dead/duplicate styles

- `zstyle ':completion:*' menu select` is set, then later `zstyle ':completion:*' menu 'select=0'` overrides it.
- `zstyle ':completion:*' matcher-list ...` is set in two places with different values; the second wins.
- `cache-path $ZSH/cache/` — `$ZSH` is unset (legacy oh-my-zsh var). This silently writes to `/cache/`. Use `~/.zsh/cache/`.
- `zstyle ':completion:*' completer _expand _complete _match _approximate` plus `_approximate` with `max-errors` is slow on every Tab. Consider dropping `_approximate` if you don't use it.

Cleanup recommended.

---

## 🟢 Low Impact / Polish

### 11. Comment cleanup

- `# zprof` line near the bottom is orphaned (and `zmodload zsh/zprof` is commented at the top). Either wire it up or remove.
- The `# fixme - the load process here seems a bit bizarre` in `completions.zsh` — time to address it 🙂.

### 12. Profile your shell

Uncomment the top `zmodload zsh/zprof` and add `zprof` at the end to measure where time is spent:

```zsh
zmodload zsh/zprof    # top of .zshrc
# ... rest ...
zprof                 # bottom of .zshrc
```

Or benchmark cold start:

```zsh
for i in {1..5}; do time zsh -i -c exit; done
```

### 13. Replace OMZ git snippet

You pull a single OMZ plugin via `zinit snippet`. If you only want the aliases, copying them into `.aliases` removes a network/IO dep. Otherwise fine.

### 14. Group related blocks

Suggested ordering:

1. Options (`setopt`, history, `WORDCHARS`)
2. PATH / env (move to `.zshenv`)
3. `fpath` setup
4. Plugin manager + plugins (turbo/wait)
5. `compinit`
6. Keybindings
7. Tool initializations (cached)
8. Prompt (`starship`)

---

## Suggested Refactored `.zshrc` (Sketch)

```zsh
# zmodload zsh/zprof  # uncomment to profile

# --- History ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE \
       HIST_FIND_NO_DUPS HIST_SAVE_NO_DUPS HIST_VERIFY \
       SHARE_HISTORY INC_APPEND_HISTORY
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT \
       EXTENDED_GLOB INTERACTIVE_COMMENTS NO_BEEP

# --- Env / PATH ---
source ~/.profile
typeset -U path PATH
path=("$HOME/.local/bin" "$PNPM_HOME" $path)

# --- fpath ---
fpath=(~/.zsh/completions ~/.zsh/cache $fpath)

# --- Zinit ---
ZINIT_HOME="$HOME/.local/share/zinit/zinit.git"
[[ -f $ZINIT_HOME/zinit.zsh ]] || {
  mkdir -p "${ZINIT_HOME:h}" && \
  git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME"
}
source "$ZINIT_HOME/zinit.zsh"

# Turbo-loaded plugins (after first prompt)
zinit wait lucid light-mode for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf \
        zsh-users/zsh-completions \
    zsh-users/zsh-history-substring-search \
    wfxr/forgit \
    OMZP::git

# --- Completion config ---
source ~/.zsh/lib/completions.zsh
[[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]] && \
  source /opt/homebrew/opt/fzf/shell/completion.zsh
[[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && \
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh

# kubectl completion regen (lazy via fpath/compinit)
if command -v kubectl &>/dev/null; then
  kc=~/.zsh/cache/_kubectl
  [[ -f $kc && -z $kc(#qN.mh+24) ]] || {
    mkdir -p ~/.zsh/cache && kubectl completion zsh > $kc
  }
fi

# --- Keybindings ---
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# --- Tool init (cached) ---
_cache_eval() {
  local name=$1; shift
  local cache=~/.zsh/cache/$name.zsh
  [[ -s $cache ]] || { mkdir -p ~/.zsh/cache; "$@" > $cache; }
  source $cache
}
_cache_eval zoxide zoxide init zsh --cmd j
_cache_eval uv     uv generate-shell-completion zsh
_cache_eval mise   ~/.local/bin/mise activate zsh
command -v wt >/dev/null && _cache_eval wt wt config shell init zsh

# --- Prompt (eager) ---
eval "$(starship init zsh)"

# zprof
```

---

## Expected Wins

| Change                               | Estimated Savings             |
| ------------------------------------ | ----------------------------- |
| Remove duplicate `source ~/.profile` | 20–80ms                       |
| `zinit wait` for plugins             | 100–300ms                     |
| Cache `eval` outputs                 | 80–200ms                      |
| Remove `fnm` (keep `mise`)           | 30–80ms                       |
| Compile `.zcompdump`                 | 30–80ms                       |
| **Total**                            | **~250–700ms** off cold start |

Run `for i in {1..5}; do time zsh -i -c exit; done` before and after to verify.

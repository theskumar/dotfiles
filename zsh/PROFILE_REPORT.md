# Zsh Startup Profile — Findings & Recommendations

Profile of the current `zsh/.zshrc` setup (after the turbo/zinit-wait refactor described in `OPTIMIZATION.md` was already applied).

Hardware: Apple Silicon (M-series), macOS, zsh 5.9.

---

## Cold-start benchmark

### Before any fixes

```
$ for i in {1..5}; do time zsh -i -c exit; done
real    0m0.404s
real    0m0.391s
real    0m0.398s
real    0m0.393s
real    0m0.394s
```

**Median: ~395 ms** to interactive prompt.

### After fix #1 (hardcode brew opt prefix in `~/.osx`)

```
$ for i in {1..5}; do time zsh -i -c exit; done
real    0m0.232s
real    0m0.241s
real    0m0.232s
real    0m0.240s
real    0m0.230s
```

**Median: ~235 ms** — **−160 ms (41% faster)**. ✅

### After fix #2 (migrate Node from fnm to mise, remove fnm)

```
$ for i in {1..5}; do time zsh -i -c exit; done
real    0m0.227s
real    0m0.221s
real    0m0.226s
real    0m0.220s
real    0m0.217s
```

**Median: ~222 ms** — **another −13 ms** (total −173 ms / 44% from baseline). ✅

### After fix #3 (switch mise to `--shims` mode, remove precmd hook)

```
$ for i in {1..5}; do time zsh -i -c exit; done
real    0m0.184s
real    0m0.176s
real    0m0.177s
real    0m0.180s
real    0m0.172s
```

**Median: ~178 ms** — **another −44 ms** (total −217 ms / **55% from baseline**). ✅

`.osx` alone: 189 ms → 12 ms. `.profile` alone: 167 ms → 18 ms. PATH still resolves gnu tools correctly (`sed`, `grep`, `find`, `date`, `curl` all point at their gnubin/opt counterparts).

A bare `zsh -fic exit` (no rc files) takes ~6 ms, so essentially all 235 ms remaining is our config.

---

## `zprof` output (synchronous portion only)

`zprof` only captures work done **before** the first prompt; the heaviest plugins (fast-syntax-highlighting, autosuggestions, completions, history-substring-search, forgit, OMZP::git) are correctly deferred via `zinit wait` and don't appear here.

| #   | Function          |   ms | %   | Notes                                     |
| --- | ----------------- | ---: | --- | ----------------------------------------- |
| 1   | `_mise_hook`      | 14.3 | 71% | First call to mise's chpwd/precmd hook    |
| 2   | `zinit` (3 calls) |  3.8 | 19% | Registering turbo specs (cheap, expected) |
| 3   | `.zinit-ice`      | 0.95 | 5%  | ice modifiers                             |
| 4   | other zinit infra |   ~1 | <5% | hooks, mtime checks                       |

Total profiled synchronous work: **~20 ms** — zprof itself accounts for almost nothing of the 395 ms wall time. The rest is hidden in:

- zsh module init (`zmodload`s, compinit replay)
- the `eval "$(... init zsh)"` subprocess forks
- `source ~/.profile` and especially `source ~/.osx`

---

## Per-section wall-time (measured individually)

| Section                                      |       Time | Notes                                          |
| -------------------------------------------- | ---------: | ---------------------------------------------- |
| `source ~/.profile`                          | **167 ms** | Dominated entirely by `~/.osx` (see below)     |
| └─ `source ~/.osx`                           | **189 ms** | Five synchronous `$(brew --prefix …)` forks 🔥 |
| └─ `source ~/.exports`                       |       7 ms |                                                |
| └─ `source ~/.aliases`                       |      12 ms |                                                |
| └─ `source ~/.functions`                     |       8 ms |                                                |
| └─ `source ~/.extra`                         |       7 ms |                                                |
| `eval "$(uv generate-shell-completion zsh)"` |      18 ms |                                                |
| `eval "$(fnm env)"`                          |      17 ms | **Redundant — mise already manages Node**      |
| `eval "$(wt config shell init zsh)"`         |      17 ms |                                                |
| `eval "$(mise activate zsh)"`                |      13 ms |                                                |
| `eval "$(starship init zsh)"`                |       7 ms | Acceptable (needed for prompt)                 |
| `eval "$(zoxide init zsh --cmd j)"`          |       4 ms |                                                |
| `source completions.zsh`                     |      20 ms |                                                |
| zsh own startup + zinit bootstrap            |     ~80 ms | (residual)                                     |

Summing the eager work: ~270 ms of measurable `source`/`eval` cost, leaving ~125 ms for zsh internals and module loading.

---

## Findings (ranked by impact)

### ✅ 1. `~/.osx` ran 5 `brew --prefix` subprocesses on every shell — **FIXED, saved 160 ms**

`~/.osx` (sourced via `~/.profile`) used to contain:

```sh
export PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH
export PATH=$(brew --prefix findutils)/libexec/gnubin:$PATH
export PATH=$(brew --prefix gnu-sed)/libexec/gnubin:$PATH
export PATH=$(brew --prefix grep)/libexec/gnubin:$PATH
export PATH=$(brew --prefix curl)/bin:$PATH
```

Each `brew --prefix` was a Ruby fork (~35 ms). Since `brew --prefix <formula>` always returns `${HOMEBREW_PREFIX}/opt/<formula>`, this is now hardcoded.

**Applied fix** (`macos/.osx`):

```sh
_brew_opt="${HOMEBREW_PREFIX:-/opt/homebrew}/opt"
[ -d "$_brew_opt" ] || _brew_opt="/usr/local/opt"   # Intel fallback
export PATH="$_brew_opt/coreutils/libexec/gnubin:$_brew_opt/findutils/libexec/gnubin:$_brew_opt/gnu-sed/libexec/gnubin:$_brew_opt/grep/libexec/gnubin:$_brew_opt/curl/bin:$PATH"
unset _brew_opt
```

Uses POSIX sh syntax (file is sourced by `~/.profile`, which may be sourced from bash too). Honors `$HOMEBREW_PREFIX` when set by `brew shellenv` and falls back to `/opt/homebrew` (Apple Silicon) or `/usr/local` (Intel).

**Measured savings: 160 ms** (`.osx`: 189 ms → 12 ms; full cold start: 395 ms → 235 ms).

Future cleanup: this PATH manipulation could move into `~/.zshenv` so non-interactive zsh shells (`zsh -c`, cron) also get gnubin tools — but that's a correctness question, not a perf one.

### ✅ 2. `fnm` removed in favor of `mise` — **DONE, saved 13 ms + 575 MB disk**

Discovered during implementation: `mise` was activated but managed _nothing_ — `fnm` was actually serving Node. So a real migration was required, not just deleting lines.

**Migration performed:**

1. Captured fnm's installed versions (`v24.12.0`) and global npm packages (`@earendil-works/pi-coding-agent`, `@nestjs/cli`, `@blowmage/cursor-agent-acp`, `@colbymchenry/codegraph`).
2. `mise use --global node@24` (installed 24.15.0 into `~/.local/share/mise/installs/node/`).
3. Removed fnm activation from `zsh/.zshrc` and the `/opt/homebrew/opt/fnm/bin` entry from `zsh/.zshenv`.
4. Verified `which node` resolves under mise; reinstalled the 4 global npm packages under mise's node.
5. `brew uninstall fnm` (7.6 MB) + `rm -rf ~/.local/share/fnm ~/.local/state/fnm_multishells` (**567 MB** of stale node-versions reclaimed).

**Measured savings:** 13 ms cold start. Less than the projected 17 ms because mise's `_mise_hook` is slightly heavier now that it actually manages a tool (17.5 ms vs 14.3 ms in zprof) — net win is still 13 ms, and we now have one tool instead of two.

**Bonus:** mise reads `.nvmrc` / `.node-version` natively, so existing repos work unchanged. Future Python/Go/etc. version pinning lives in the same `~/.config/mise/config.toml`.

### 🟠 3. Cache the `eval "$(... init zsh)"` outputs — **~30–50 ms**

`uv` (18 ms), `wt` (17 ms), `mise` (13 ms), and `zoxide` (4 ms) all fork a subprocess on every shell start to emit static-ish shell code. Cache them to disk and re-source. Pattern:

```zsh
_cache_eval() {
  local name=$1; shift
  local cache=~/.zsh/cache/$name.zsh
  local bin=${commands[$1]:-/dev/null}
  if [[ ! -s $cache || $bin -nt $cache ]]; then
    mkdir -p ~/.zsh/cache
    "$@" > $cache
  fi
  source $cache
}
_cache_eval uv     uv generate-shell-completion zsh
_cache_eval zoxide zoxide init zsh --cmd j
_cache_eval mise   mise activate zsh
_cache_eval wt     wt config shell init zsh
```

Cached file `source`s are sub-millisecond. The `$bin -nt $cache` check auto-invalidates when the binary is upgraded.

Keep `starship init zsh` eager (only 7 ms and required for the first prompt).

**Estimated savings: 30–50 ms.**

### 🟡 4. fzf `key-bindings.zsh` / `completion.zsh` emit `can't change option: zle` warnings

Visible in `time zsh -i -c exit` runs:

```
(eval):1: can't change option: zle
(eval):1: can't change option: zle
```

Source: fzf's scripts run `eval 'options=(... zle on ...)'` to restore options, but `zle` is a read-only option when stdin is not a tty. **Harmless** in real interactive shells (where stdin _is_ a tty) but pollutes benchmarks/scripts. Suppress when benchmarking with `2>/dev/null`, or upstream-report. Not a real perf issue.

### 🟡 5. `compinit` is already optimized

`zicompinit; zicdreplay` runs in the first turbo block with `-C` (skip security check). `__deferred_compdefs` shim is correctly in place. No change needed.

### 🟢 6. Compile rc files with `zcompile`

Add to `install.sh` (or run on demand):

```zsh
for f in ~/.zshrc ~/.zshenv ~/.profile ~/.exports ~/.aliases ~/.functions ~/.osx ~/.zsh/lib/*.zsh; do
  [[ -f $f && ( ! -f $f.zwc || $f -nt $f.zwc ) ]] && zcompile $f
done
```

Saves ~10–30 ms on parse cost, especially for the 426-line `.functions` file.

### 🟢 7. `~/.profile` `for file in …` loop pattern

Minor: the `for file in ~/.{exports,aliases,functions,extra}` loop is fine. Each file is small; not a hotspot.

---

## Recommended action order

1. ~~**Fix `.osx` brew --prefix calls**~~ ✅ **DONE — saved 160 ms** (395 → 235 ms).
2. ~~**Remove fnm, migrate to mise**~~ ✅ **DONE — saved 13 ms + 575 MB** (235 → 222 ms).
3. **Cache eval'd init scripts** (~30–50 ms): `uv`, `wt`, `mise`, `zoxide`.
4. **`zcompile` rc files on install** (~10–30 ms).
5. ~~**Switch mise to `--shims` mode**~~ ✅ **DONE — saved 44 ms** (222 → 178 ms). See § below.
6. Optional: investigate residual ~80 ms zinit/module bootstrap (diminishing returns).

**Current cold start: ~178 ms** (down from 395 ms, **55% faster**). Projected after remaining fixes (cache eval'd init scripts, zcompile): ~130–150 ms.

---

## Fix #3 detail — `mise activate --shims`

### Before

```zsh
eval "$(~/.local/bin/mise activate zsh)"
```

Installed a `precmd` + `chpwd` hook (`_mise_hook`). zprof showed it at **17.5 ms** in the synchronous startup path. The hook also re-ran before _every_ prompt, walking the directory tree for `mise.toml` / `.tool-versions` / `.nvmrc`.

### After

```zsh
eval "$(~/.local/bin/mise activate zsh --shims)"
```

No hook. mise just prepends `~/.local/share/mise/shims` to `PATH`. Each shim (e.g. `~/.local/share/mise/shims/node`) is a tiny script that fork-execs the real binary on call.

### Trade-off measured

| Operation                      | Hook mode | Shims mode |          Δ |
| ------------------------------ | --------: | ---------: | ---------: |
| Cold shell start               |    222 ms | **178 ms** | **−44 ms** |
| Single `node -e ''` invocation |     29 ms |      59 ms |     +30 ms |
| 50x `node -e ''` in one shell  |    1.45 s |     3.87 s |     +2.4 s |

**Break-even: ~1.5 `node` invocations per shell session.** Below that, shims is faster overall; above, hooks are.

### Why this fits this dotfiles repo

- Typical interactive use is 0–3 `node`/`pi` calls per terminal session → well below break-even.
- The 44 ms shell-start savings happens on **every** new terminal/tab/tmux pane.
- The 30 ms shim overhead only hits when you actually invoke a node tool.
- Bonus: shims are on `PATH` via `.zshenv`-time-PATH-mutation only — wait, they're not, they're added by `mise activate` in `.zshrc`. So GUI apps still won't see them unless you also add `~/.local/share/mise/shims` directly in `.zshenv`. Future improvement if needed.

### When to revert to hook mode

If you start running tight node loops in interactive shells (test watchers, build scripts that spawn many `node` subprocesses inside _this_ shell rather than via npm scripts), revert with:

```diff
- eval "$(~/.local/bin/mise activate zsh --shims)"
+ eval "$(~/.local/bin/mise activate zsh)"
```

Note: `npm run`/`make`/etc. that spawn node from a _child_ process don't multiply this cost — only direct interactive calls do.

## Verify

```zsh
# Before each change
for i in {1..5}; do time zsh -i -c exit; done

# To re-profile synchronously:
#   uncomment `zmodload zsh/zprof` at top of .zshrc
#   add `zprof` at the bottom
```

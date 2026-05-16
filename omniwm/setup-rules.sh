#!/usr/bin/env bash
# omniwm/setup-rules.sh
#
# Applies one-time OmniWM window rules that cannot live in settings.toml.
# (settings.toml only supports min-size constraints; float/tile rules are
# persisted by OmniWM's IPC layer and survive across restarts.)
#
# Run once after a fresh install or after resetting OmniWM's state.
# Safe to re-run — upgrades existing "auto" rules to "float", skips rules
# already set to "float".
#
# Requirements:
#   - OmniWM must be running with IPC enabled (general.ipcEnabled = true)
#   - omniwmctl must be on PATH (install via OmniWM menu → "Install CLI to PATH")

set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────────────

check_ipc() {
  if ! omniwmctl ping &>/dev/null; then
    echo "✗ Cannot reach OmniWM IPC." >&2
    echo "  Make sure OmniWM is running and ipcEnabled = true in settings.toml." >&2
    exit 1
  fi
}

# Ensure float rule for a given app.
#   float already  → skip
#   auto rule      → replace in-place with float (preserve min sizes)
#   no rule        → add float rule
ensure_float_rule() {
  local bundle_id="$1"
  local app_name="$2"

  local rules_json
  rules_json="$(omniwmctl query rules --format json)"

  local rule_info
  rule_info="$(echo "$rules_json" | python3 -c "
import json, sys
bundle_id = sys.argv[1]
data = json.load(sys.stdin)
rules = data.get('result', {}).get('payload', {}).get('rules', [])
match = next((r for r in rules if r.get('bundleId') == bundle_id), None)
if match:
    print('{}|{}|{}|{}'.format(
        match['id'],
        match['layout'],
        match.get('minWidth', ''),
        match.get('minHeight', '')
    ))
else:
    print('NONE')
" "$bundle_id")"

  if [[ "$rule_info" == "NONE" ]]; then
    omniwmctl rule add --bundle-id "$bundle_id" --layout float
    echo "  ✓ $app_name: float rule added"
  else
    IFS='|' read -r rule_id current_layout min_width min_height <<< "$rule_info"
    if [[ "$current_layout" == "float" ]]; then
      echo "  → $app_name: already float, skipping"
    else
      local cmd=(omniwmctl rule replace "$rule_id" --bundle-id "$bundle_id" --layout float)
      [[ -n "$min_width"  ]] && cmd+=(--min-width  "$min_width")
      [[ -n "$min_height" ]] && cmd+=(--min-height "$min_height")
      "${cmd[@]}"
      echo "  ✓ $app_name: upgraded '$current_layout' → float (rule $rule_id)"
    fi
  fi
}

print_float_rules() {
  local rules_json
  rules_json="$(omniwmctl query rules --format json)"
  echo "$rules_json" | python3 -c "
import json, sys
data = json.load(sys.stdin)
rules = data.get('result', {}).get('payload', {}).get('rules', [])
floats = [r for r in rules if r.get('layout') == 'float']
if floats:
    print('  {:<40} {:<8} {}'.format('BUNDLE ID', 'LAYOUT', 'RULE ID'))
    print('  {:<40} {:<8} {}'.format('-'*40, '-'*8, '-'*36))
    for r in floats:
        print('  {:<40} {:<8} {}'.format(r.get('bundleId',''), r.get('layout',''), r.get('id','')))
else:
    print('  (none)')
"
}

# ── main ─────────────────────────────────────────────────────────────────────

echo "==> Checking OmniWM IPC…"
check_ipc
echo "    Connected ($(omniwmctl version))"
echo ""

echo "==> Applying float rules…"

# Apps that should always float (never be tiled).
# Add more entries here as needed.
ensure_float_rule "com.dmitrynikolaev.numi"  "Numi"
ensure_float_rule "com.todoist.mac.Todoist"  "Todoist"

echo ""
echo "==> Current float rules:"
print_float_rules

echo ""
echo "Done. Rules are persisted by OmniWM and survive restarts."

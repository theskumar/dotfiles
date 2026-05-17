#!/usr/bin/env bash
# bookmark-kb.sh — save a newsboat article to cowork-kb/raw/clips/
#
# Usage (called by newsboat bookmark-autopilot):
#   bookmark-kb.sh <url> <title> [<description>] [<feed_title>]
#
# Saves a clean markdown file to ~/Documents/cowork-kb/raw/clips/<slug>.md
# using Mozilla Readability (readable-cli) for content extraction.
#
# Requirements:
#   - readable-cli: npm install -g readability-cli
#
# Newsboat config:
#   bookmark-cmd "~/.config/newsboat/scripts/bookmark-kb.sh"
#   bookmark-autopilot yes

set -euo pipefail

URL="${1:-}"
TITLE="${2:-Untitled}"
# $3 = description, $4 = feed_title (available but unused here)

KB_DIR="$HOME/Documents/cowork-kb/raw/clips"
mkdir -p "$KB_DIR"

# ─── Slug from title ──────────────────────────────────────────────────────────
slug=$(echo "$TITLE" \
  | tr '[:upper:]' '[:lower:]' \
  | sed 's/[^a-z0-9]/-/g' \
  | sed 's/--*/-/g' \
  | sed 's/^-//;s/-$//' \
  | cut -c1-60)
slug="${slug:-untitled}"

# Avoid overwriting: append date if file exists
DATE=$(date +%Y-%m-%d)
OUTFILE="$KB_DIR/${DATE}-${slug}.md"
if [[ -f "$OUTFILE" ]]; then
  OUTFILE="$KB_DIR/${DATE}-${slug}-$(date +%H%M%S).md"
fi

# ─── Fetch and clean article content ─────────────────────────────────────────
content=""
if command -v readable &>/dev/null && [[ -n "$URL" ]]; then
  content=$(readable "$URL" --quiet 2>/dev/null || echo "")
fi

# ─── Write markdown file ──────────────────────────────────────────────────────
cat > "$OUTFILE" <<EOF
---
title: "${TITLE//\"/\'}"
url: ${URL}
saved: ${DATE}
source: newsboat
---

${content}
EOF

# Notify (macOS)
if command -v osascript &>/dev/null; then
  osascript -e "display notification \"Saved to cowork-kb\" with title \"${TITLE:0:60}\"" 2>/dev/null || true
fi

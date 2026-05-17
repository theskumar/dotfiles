#!/usr/bin/env bash
# newsboat article pager: render markdown with glow -p
# Called by newsboat as: pager.sh <tempfile>
#
# newsboat's tempfile has no extension — glow won't detect it as markdown
# and falls back to plain text (showing raw link syntax, wrong colours).
# Copy to a .md file so glow renders it properly.

tmpmd=$(mktemp /tmp/nb-article.XXXX.md)
cp "$1" "$tmpmd"
glow -p "$tmpmd"
rm -f "$tmpmd"

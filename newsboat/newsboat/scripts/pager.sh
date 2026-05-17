#!/usr/bin/env bash
# newsboat article pager: render markdown with glow, page with less
# Called by newsboat as: pager.sh <tempfile>
#
# Pipeline:
#   newsboat html-renderer (pandoc) → markdown tempfile → glow → less -R
# glow -p uses glow's built-in TUI pager — full colour, always waits for input
exec glow -p "$1"

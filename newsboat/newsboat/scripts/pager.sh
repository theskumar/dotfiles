#!/usr/bin/env bash
# newsboat article pager: render markdown with glow, page with less
# Called by newsboat as: pager.sh <tempfile>
#
# Pipeline:
#   newsboat html-renderer (pandoc) → markdown tempfile → glow → less -R
exec glow "$1" | less -R

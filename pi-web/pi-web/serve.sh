#!/bin/bash
# Expose pi-web over HTTPS on the tailnet.
# Run once. tailscaled persists the serve config across reboots.
#
# Prerequisites (Tailscale admin console):
#   - HTTPS certificates enabled (DNS page)
#   - tag:pi-web in tagOwners, and svc:pi-web defined (port 443) with a grant
#   - an admin approves this node as host of svc:pi-web
#
# Result:
#   https://pi-web.<tailnet>.ts.net        (service, needs tagged node)
#   https://<machine>.<tailnet>.ts.net         (node, always works)
set -euo pipefail
TS="${TAILSCALE:-/Applications/Tailscale.app/Contents/MacOS/Tailscale}"
PORT="${PORT:-30141}"
TAG="${TAG:-tag:pi-web}"

# Service hosts must be tagged nodes. `tailscale set` has no tag flag on macOS.
if ! "$TS" status --json | grep -q "\"$TAG\""; then
  "$TS" up --advertise-tags="$TAG"
fi

"$TS" serve --bg --https=443 "http://localhost:${PORT}"
"$TS" serve --service=svc:pi-web --https=443 "http://localhost:${PORT}"
"$TS" serve status

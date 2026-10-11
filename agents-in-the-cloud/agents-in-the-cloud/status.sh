#!/bin/zsh
# Show AgentsInTheCloud access state: mode, Tailscale login URL, app URL.
# Usage: status.sh [connect]
#   connect  switch the System to Tailscale mode (joins the tailnet as its own node)
set -eu
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
SYS=agents-in-the-cloud-system
if [ "${1:-}" = connect ]; then
  docker exec "$SYS" bun -e 'const r=await fetch("http://127.0.0.1:3001/access",{method:"POST",headers:{"content-type":"application/json"},body:JSON.stringify({mode:"tailscale"})});if(!r.ok)throw new Error(String(r.status))'
  sleep 10
fi
docker exec "$SYS" bun -e '
const s = await (await fetch("http://127.0.0.1:3001/status")).json();
const a = await (await fetch("http://127.0.0.1:3001/access")).json();
console.log("state:   ", s.state, "-", s.activity?.description ?? "");
console.log("mode:    ", a.mode, "-", a.connectionState ?? "");
if (a.authUrl) console.log("approve: ", a.authUrl);
console.log("open:    ", a.origin ?? (s.tailnetHost ? "https://" + s.tailnetHost : "(not ready)"));
'

# AgentsInTheCloud

Trial install of [AgentsInTheCloud](https://agentsinthecloud.com), reached from the phone over Tailscale.
Runbook: cowork-kb `_meta/plans/2026-10-10-agentsinthecloud-trial.md`.

## Shape

- The installer runs a privileged `agents-in-the-cloud-system` container in OrbStack with `--restart unless-stopped`.
- Access mode is `tailscale`. The System runs its own tailscaled and joins the personal tailnet as the node `agents-in-the-cloud-system`.
- App URL: `https://agents-in-the-cloud-system.tail2b5698.ts.net`. Workspace previews get `https://<node>:41xxx` origins.
- The local origin `http://agents-in-the-cloud.localhost:3080` also works on the Mac.
- No LaunchAgent is needed. Docker restarts the container, and the tailnet state lives in the System volume.
- OrbStack must start at login: `orb config set app.start_at_login true`.

A Mac-side `tailscale serve` proxy (the pi-web pattern) does not work here.
The System's local ingress routes by Host header and only accepts `*.agents-in-the-cloud.localhost`.

## Install

```shell
curl -fsSL https://raw.githubusercontent.com/lucasmeijer/AgentsInTheCloud/main/scripts/install.sh -o /tmp/aitc-install.sh
script -q /dev/null bash /tmp/aitc-install.sh --access-mode tailscale
~/.config/agents-in-the-cloud/status.sh
```

The installer needs a TTY. `script` provides one when no terminal is attached.
Open the `approve:` URL from `status.sh` on a device logged in to the tailnet.

## Slow image pulls

This ISP routes IPv4 to GitHub's package CDN at about 150 KiB/s. IPv6 is fast.
OrbStack containers use IPv4, so the System's pull of the 2 GB workspace image times out after 30 minutes.
Fix: preload the image from the Mac, then restart the System.

```shell
~/.config/agents-in-the-cloud/preload-images.py
docker restart agents-in-the-cloud-system
```

## Security

The app has no authentication.
Anyone on the tailnet can drive every workspace.
Keep it on the personal tailnet only.

## Remove

```shell
bash /tmp/aitc-install.sh --uninstall
```

Then remove the `agents-in-the-cloud-system` machine in the Tailscale admin console.

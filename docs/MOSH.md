# mosh

Mobile shell. Survives Wi-Fi roaming, suspend/resume, and high-latency links.
Local echo prediction makes typing feel instant.

## Install

Already covered by `setup/setup_mac.sh` (`brew install mosh`) on macOS. On
Linux servers:

```bash
sudo apt install mosh        # Debian/Ubuntu
sudo dnf install mosh        # Fedora/RHEL
```

Mosh must be installed on **both** client and server.

## Shell setup

Wired into `shell/.exports` and `shell/.aliases` (stowed to `$HOME`):

- `MOSH_TITLE_NOPREFIX=1` — keep terminal title clean
- `MOSH_PREDICTION_DISPLAY=adaptive` — local echo on slow links only
- `MOSH_SERVER_NETWORK_TMOUT=604800` — detach idle session after 7 days
- `alias mosh` — sets server locale to `en_US.UTF-8` and adaptive prediction
- `alias mosh-pin` — pins UDP port 60001 (use behind strict firewalls)

## Connecting

```bash
mosh user@host                       # uses ssh for handshake, then UDP
mosh --ssh="ssh -p 2222" user@host   # custom ssh port
mosh -p 60001 user@host              # pin UDP port (must be open on server)
```

## Firewall

Mosh uses **UDP 60000–61000** by default. On the server, open the range or
pin a single port with `-p`:

```bash
# Linux (ufw)
sudo ufw allow 60000:61000/udp

# Linux (firewalld)
sudo firewall-cmd --permanent --add-port=60000-61000/udp && sudo firewall-cmd --reload
```

On macOS the firewall is per-app; if hosting `mosh-server`, allow it under
System Settings → Network → Firewall.

## Reattaching / tmux

Mosh has no built-in reattach. Pair it with tmux:

```bash
mosh user@host -- tmux new -A -s main
```

## Troubleshooting

- "mosh-server not found" — install mosh on the server, or pass
  `--server=/path/to/mosh-server`.
- Garbled characters — ensure server has a UTF-8 locale (the alias sets
  `LANG=en_US.UTF-8`).
- Stuck on "Connecting…" — UDP 60000–61000 is blocked. Use `-p` and open one
  port, or fall back to ssh.

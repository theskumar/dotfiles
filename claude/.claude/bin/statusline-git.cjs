#!/usr/bin/env node
// Statusline wrapper: prints "<repo-folder> <branch>" then the cc-hud line.
// Reads the Claude Code statusline JSON on stdin and forwards it unchanged to
// ~/.claude/bin/cc-hud-launcher.cjs. Silent on any failure — never blocks Claude Code.

'use strict';

const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const { spawnSync } = require('node:child_process');

const LAUNCHER = path.join(os.homedir(), '.claude', 'bin', 'cc-hud-launcher.cjs');
const SPAWN_TIMEOUT_MS = 3000;

// Catppuccin Mocha
const DIR = '\x1b[38;2;137;180;250m'; // blue
const BRANCH = '\x1b[38;2;203;166;247m'; // mauve
const DIM = '\x1b[38;2;108;112;134m'; // overlay0
const RESET = '\x1b[0m';

function git(cwd, args) {
  const res = spawnSync('git', args, {
    cwd,
    encoding: 'utf8',
    timeout: 1000,
    windowsHide: true,
  });
  if (!res || res.status !== 0 || typeof res.stdout !== 'string') return null;
  const out = res.stdout.trim();
  return out || null;
}

function gitSegment(cwd) {
  const root = git(cwd, ['rev-parse', '--show-toplevel']);
  if (!root) return null;
  const folder = path.basename(root);
  let branch = git(cwd, ['rev-parse', '--abbrev-ref', 'HEAD']);
  if (!branch || branch === 'HEAD') {
    branch = git(cwd, ['rev-parse', '--short', 'HEAD']);
  }
  const name = `${DIR}${folder}${RESET}`;
  if (!branch) return name;
  return `${name} ${DIM}⎇${RESET} ${BRANCH}${branch}${RESET}`;
}

const EFFORT_STYLE = {
  low: { label: 'low', color: '\x1b[38;2;166;227;161m' }, // green
  medium: { label: 'med', color: '\x1b[38;2;249;226;175m' }, // yellow
  high: { label: 'high', color: '\x1b[38;2;250;179;135m' }, // peach
  max: { label: 'max', color: '\x1b[38;2;243;139;168m' }, // red
};

function effortSegment(level) {
  if (!level) return null;
  const key = String(level).toLowerCase();
  const style = EFFORT_STYLE[key] || { label: key, color: BRANCH };
  return `${style.color}${style.label}${RESET}`;
}

// cc-hud renders the model as OVERLAY[ BLUE<name> OVERLAY]. Splice the effort in
// before the closing bracket so the two read as one unit: [Opus 5 · med].
const HUD_OVERLAY = '\x1b[38;5;243m';
const HUD_CLOSE = `${HUD_OVERLAY}]${RESET}`;

function spliceEffort(hud, effort) {
  if (!hud) return null;
  if (!effort) return hud;
  const at = hud.indexOf(HUD_CLOSE);
  if (at === -1) return hud;
  const insert = ` ${HUD_OVERLAY}·${RESET} ${effort}`;
  return hud.slice(0, at) + insert + hud.slice(at);
}

function main() {
  let raw = '';
  try {
    raw = fs.readFileSync(0, 'utf8');
  } catch {}

  let cwd = process.cwd();
  let effort = null;
  try {
    const data = JSON.parse(raw);
    cwd = data?.workspace?.current_dir || data?.cwd || cwd;
    effort = effortSegment(data?.effort?.level);
  } catch {}

  const segment = gitSegment(cwd);

  let hud = '';
  try {
    const res = spawnSync(process.execPath, [LAUNCHER], {
      input: raw,
      encoding: 'utf8',
      windowsHide: true,
      timeout: SPAWN_TIMEOUT_MS,
      killSignal: 'SIGKILL',
    });
    if (res && typeof res.stdout === 'string') hud = res.stdout.trim();
  } catch {}

  // If cc-hud produced no output, fall back to the effort as its own segment.
  const modelAndEffort = hud
    ? spliceEffort(hud, effort)
    : effort && `${DIM}⚡${RESET}${effort}`;

  const parts = [segment, modelAndEffort].filter(Boolean);
  process.stdout.write(parts.join(`  ${DIM}|${RESET}  `) + '\n');
}

process.on('uncaughtException', () => {});
process.on('unhandledRejection', () => {});
main();

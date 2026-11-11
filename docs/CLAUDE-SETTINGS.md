# Claude Code settings: keeping the system prompt lean

File: `claude/.claude/settings.json` (stowed to `~/.claude/settings.json`).

## Why

Claude Code sends every tool definition, skill listing, connector and
feature instruction with **every request**. Anything in there that I never
use still costs tokens on each turn, eats context, and can push the model
toward behaviour I don't want (opening plan mode, asking menu-style
questions, offering connectors).

The rule I follow: if I don't use it, take it out of the prompt. After each
change, restart Claude Code and run `/context` to check the effect.

With the settings below, a fresh session here starts at **7.9k**
(system prompt 1.9k, tools 4.9k, skills 0.6k), measured with `/context` on
2026-11-11. Your numbers depend on which plugins, connectors and MCP servers
you have.

## What's turned off and why

| Setting | What it removes | Why |
|---|---|---|
| `disableClaudeAiConnectors: true` | Every claude.ai connector (Slack, Notion, Malcolm, Google, …) and its instructions | I reach Slack and Malcolm through skills instead (see below). |
| `disableWorkflows: true` (+ `enableWorkflows: false`, `workflowKeywordTriggerEnabled: false`) | Workflow orchestration instructions | I don't use workflows. |
| `disableBundledSkills: true` | Built-in skills (deep research, data viz, etc.) | Not used. My own skills still load. |
| `disableArtifact: true` | Artifact tool and its instructions | Not used in the terminal. |
| `feedbackDrafts: "off"` | `SendFeedback` tool | Not needed. |
| `syncClaudeAiSkills: false` | Skills synced from my claude.ai account (docs, docx, pdf, pptx, xlsx, google-workspace, morning, import-memory) | ~2k tokens of skills I don't use in the terminal. Needs a fresh launch, not `/resume`. Synced copies move to `~/.claude/skills/.trash`; removing the setting downloads them again. |
| `enabledPlugins: { "<name>@synced": false }` | Organisation plugins synced from claude.ai: `rosey-studio-pm-kit`, `cowork-plugin-management`, `rosey-studio-reporting-activation` | 13 skills I don't use. Turned off by name, so new organisation plugins still load. `syncClaudeAiPlugins: false` would block all of them. |
| `permissions.deny` list | The definition of each tool listed | A denied tool's definition is removed from the prompt entirely, not just blocked at runtime. |

Denied tools: `EnterPlanMode`, `ExitPlanMode`, `DesignSync`, `NotebookEdit`,
`SendMessage`, `PushNotification`, `RemoteTrigger`, `ReportFindings`,
`ScheduleWakeup`, `AskUserQuestion` (long definition; I prefer plain
questions), `CronCreate`, `CronDelete`, `CronList`, `ShareOnboardingGuide`,
`ListAgents`, `PublishPlugin`, `EndConversation`.

These were picked by checking which tools I'd actually used in 60 days of
session logs (`~/.claude/projects/*.jsonl`). Blocking the last four took a
fresh session from 8.7k to 7.9k. Kept on purpose: `EnterWorktree` and
`ExitWorktree`.

## Slack and Malcolm still work

Turning off connectors only removes them from Claude Code's prompt. The
connectors stay linked on claude.ai.

My skills call Anthropic's connector service directly with my Claude login.
There's no model call and they don't go through Claude Code's tools:

- Slack: `~/code/agent-stuff/skills/slack/scripts/slack.mjs`
- Malcolm: `~/Documents/cowork-kb/.claude/skills/malcolm/scripts/malcolm.mjs`

Both were checked working with `disableClaudeAiConnectors: true`. Run
`node <script> auth` to check either one.

## Undoing

To bring something back, set the setting to `false`, or remove the tool from
`permissions.deny`, then restart Claude Code.

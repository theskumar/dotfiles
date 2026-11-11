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

One source walkthrough brought a fresh session from about 68k tokens down
to about 20k with these settings. Your numbers depend on which plugins,
connectors and MCP servers you have.

## What's turned off and why

| Setting | What it removes | Why |
|---|---|---|
| `disableClaudeAiConnectors: true` | Every claude.ai connector (Slack, Notion, Malcolm, Google, …) and its instructions | The biggest single saving (~20k tokens). I reach Slack and Malcolm through skills instead (see below). |
| `disableWorkflows: true` (+ `enableWorkflows: false`, `workflowKeywordTriggerEnabled: false`) | Workflow orchestration instructions | I don't use workflows. |
| `disableBundledSkills: true` | Built-in skills (deep research, data viz, etc.) | Not used. My own skills still load. |
| `disableArtifact: true` | Artifact tool and its instructions | Not used in the terminal. |
| `feedbackDrafts: "off"` | `SendFeedback` tool | Not needed. |
| `permissions.deny` list | The definition of each tool listed | A denied tool's definition is removed from the prompt entirely, not just blocked at runtime. |

Denied tools: `EnterPlanMode`, `ExitPlanMode`, `DesignSync`, `NotebookEdit`,
`SendMessage`, `PushNotification`, `RemoteTrigger`, `ReportFindings`,
`ScheduleWakeup`, `AskUserQuestion` (long definition; I prefer plain
questions), `CronCreate`, `CronDelete`, `CronList`.

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

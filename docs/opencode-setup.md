# Using super-agent-skills with OpenCode

This guide explains how to use super-agent-skills with OpenCode in a way that closely mirrors the Claude Code experience -- automatic skill selection, lifecycle-driven workflows, and strict process enforcement.

## Overview

OpenCode does not have a native plugin system or automatic skill routing like Claude Code. Instead, we achieve parity through:

- A strong system prompt (`AGENTS.md` at the repo root)
- Consistent skill discovery from the `skills/` directory
- Agent-driven intent mapping

This creates an **agent-driven workflow** where skills are selected and executed automatically based on what you ask for, without requiring manual command invocation.

## Installation

1. Clone the repository:

```bash
git clone https://github.com/oscarqjh/super-agent-skills.git
```

2. Open the project in OpenCode (or ensure the repo is in your workspace).

3. Ensure the following files are present and accessible:

- `AGENTS.md` (repo root)
- `skills/` directory with all 24 skill subdirectories

No additional installation is required. The `AGENTS.md` file instructs the agent on how to discover and use skills.

## How It Works

### 1. Skill Discovery

All skills live in:

```
skills/<skill-name>/SKILL.md
```

The agent is instructed (via `AGENTS.md`) to:

- Detect when a skill applies to the current task
- Read the relevant `SKILL.md` file
- Follow the skill workflow exactly

### 2. Automatic Skill Invocation

The agent evaluates every request and maps it to the appropriate skill. Examples:

- "Build a feature" -> `brainstorming` (starts the chain)
- "Plan this change" -> `writing-plans`
- "Fix a bug" -> `systematic-debugging`
- "Review this code" -> `requesting-code-review`
- "Write tests for this" -> `test-driven-development`
- "Simplify this module" -> `code-simplification`
- "Ship it" -> `finishing-a-development-branch`

You do **not** need to explicitly request skills. The agent selects them based on intent.

### 3. Lifecycle Mapping (Implicit Commands)

The development lifecycle is encoded as implicit phases. Since OpenCode does not support slash commands like `/spec` or `/plan`, the agent maps your intent to the lifecycle internally:

| Phase | Skill | Trigger Phrases |
|-------|-------|----------------|
| DEFINE | `brainstorming` | "build", "create", "new feature", "I want to" |
| PLAN | `writing-plans` | "plan", "break down", "task list" |
| BUILD | `subagent-driven-development` + domain skills | "implement", "execute the plan" |
| VERIFY | `systematic-debugging` + `verification-before-completion` | "fix", "debug", "broken" |
| REVIEW | `requesting-code-review` | "review", "check my code" |
| SHIP | `finishing-a-development-branch` | "ship", "merge", "PR", "done" |

## Usage Examples

### Example 1: Feature Development

User:
```
Add authentication to this app
```

Agent behavior:
- Detects feature work
- Reads and follows `skills/brainstorming/SKILL.md`
- Produces a design spec before writing code
- Moves to `writing-plans` for task breakdown
- Implements using `subagent-driven-development` patterns (with TDD, incremental implementation)
- Requests code review via `requesting-code-review`
- Finishes via `finishing-a-development-branch`

### Example 2: Bug Fix

User:
```
This endpoint is returning 500 errors
```

Agent behavior:
- Reads and follows `skills/systematic-debugging/SKILL.md`
- Reproduces -> localizes -> identifies root cause -> fixes
- Uses `test-driven-development` (Prove-It pattern: write failing test first)

### Example 3: Code Review

User:
```
Review my changes before merging
```

Agent behavior:
- Reads and follows `skills/requesting-code-review/SKILL.md`
- Applies structured 5-axis review (correctness, readability, architecture, security, performance)

## Driving the Chain Manually

In OpenCode, the orchestration chain does not auto-handoff between skills. After each skill completes, you prompt the next phase:

1. "I want to build X" -> agent runs brainstorming, produces spec
2. "Now plan the implementation" -> agent runs writing-plans
3. "Execute the plan" -> agent runs subagent-driven-development patterns
4. "Review the code" -> agent runs requesting-code-review
5. "Ship it" -> agent runs finishing-a-development-branch

Each skill tells you what the next step in the chain is.

## Agent Expectations

For OpenCode to work correctly, the agent must follow these rules (enforced via `AGENTS.md`):

- Always check if a skill applies before acting
- If a skill applies, it MUST be used
- Never skip required workflows (brainstorm, plan, test, etc.)
- Do not jump directly to implementation
- Follow each skill's verification steps before claiming completion

## Limitations vs Claude Code

- No native slash commands (handled via intent mapping instead)
- No automatic skill-to-skill handoffs (you drive the chain manually)
- No session-start hook (the agent relies on `AGENTS.md` for guidance)
- No `super-agent-skills:` namespace (skills are referenced by reading SKILL.md files)
- Skill invocation depends on model compliance with `AGENTS.md` instructions

Despite these, the workflow closely matches Claude Code in practice when the agent follows `AGENTS.md` faithfully.

## Summary

OpenCode integration works by combining:

- Structured skills (this repo's `skills/` directory)
- Strong agent rules (`AGENTS.md`)
- Automatic skill invocation via intent reasoning

This results in a fully agent-driven engineering workflow without requiring plugins or manual commands.

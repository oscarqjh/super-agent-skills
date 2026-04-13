# AGENTS.md

This file provides guidance to AI coding agents (OpenCode, Cursor, Copilot, Gemini CLI, Windsurf, etc.) when working with code in this repository.

## Repository Overview

super-agent-skills is a collection of 24 skills for AI coding agents that combines orchestration (brainstorm, plan, execute, review, ship) with production-grade engineering standards (anti-rationalizations, 5-axis code review, OWASP, Hyrum's Law, TDD).

Skills are packaged as Markdown files (`SKILL.md`) with YAML frontmatter. When loaded into an agent's context, the agent follows the workflow step-by-step, including verification steps, anti-patterns to avoid, and exit criteria.

### Directory Structure

```
super-agent-skills/
  skills/           24 skills (each in skills/<name>/SKILL.md)
  agents/           3 subagent personas (code-reviewer, test-engineer, security-auditor)
  references/       4 checklists (security, performance, testing, accessibility)
  commands/         9 slash commands (Claude Code only)
  hooks/            Session-start hook (Claude Code only)
```

### The Orchestration Chain

For any building/creation task, the default lifecycle is:

```
brainstorming -> writing-plans -> subagent-driven-development -> requesting-code-review -> finishing-a-development-branch
```

Domain skills (TDD, security, API design, frontend, etc.) auto-trigger during implementation based on context.

## OpenCode Integration

OpenCode uses a **skill-driven execution model** powered by this repository's `skills/` directory and this `AGENTS.md` file.

### Core Rules

- If a task matches a skill, you MUST invoke it
- Skills are located in `skills/<skill-name>/SKILL.md`
- Never implement directly if a skill applies
- Always follow the skill instructions exactly (do not partially apply them)

### Intent -> Skill Mapping

The agent should automatically map user intent to skills:

- Feature / new functionality -> `brainstorming` (starts the full orchestration chain)
- Planning / task breakdown -> `writing-plans`
- Execute a plan -> `subagent-driven-development` (or `executing-plans`)
- Code review -> `requesting-code-review`
- Finish / merge / PR -> `finishing-a-development-branch`
- Bug / failure / unexpected behavior -> `systematic-debugging`
- Writing or running tests -> `test-driven-development`
- Implementing code -> `incremental-implementation`
- API or interface design -> `api-and-interface-design`
- UI work -> `frontend-ui-engineering`
- Security concerns -> `security-and-hardening`
- Performance work -> `performance-optimization`
- Refactoring / simplification -> `code-simplification`
- Writing docs or ADRs -> `documentation-and-adrs`
- Multiple independent tasks -> `dispatching-parallel-agents`
- Browser-based testing -> `browser-testing-with-devtools`
- Using frameworks/libraries -> `source-driven-development`

### Lifecycle Mapping (Implicit Commands)

OpenCode does not support slash commands like `/spec` or `/plan`.

Instead, the agent must internally follow this lifecycle:

- DEFINE -> `brainstorming`
- PLAN -> `writing-plans`
- BUILD -> `subagent-driven-development` + domain skills as needed
- VERIFY -> `systematic-debugging` + `verification-before-completion`
- REVIEW -> `requesting-code-review`
- SHIP -> `finishing-a-development-branch`

### Execution Model

For every request:

1. Determine if any skill applies (even 1% chance)
2. Read the appropriate `skills/<name>/SKILL.md` file
3. Follow the skill workflow strictly
4. Only proceed to implementation after required steps (brainstorm, plan, etc.) are complete

### Anti-Rationalization

The following thoughts are incorrect and must be ignored:

- "This is too small for a skill"
- "I can just quickly implement this"
- "I'll gather context first"
- "This doesn't need a formal skill"
- "The skill is overkill for this"

Correct behavior:

- Always check for and use skills first

This ensures OpenCode behaves similarly to Claude Code with full workflow enforcement.

## Skill Discovery (Non-Plugin Environments)

In environments that do not support the `super-agent-skills:` namespace (i.e., everything except Claude Code), you can still use these skills by reading the SKILL.md files directly.

### How to Use a Skill

1. Identify the relevant skill from the intent mapping above
2. Read `skills/<skill-name>/SKILL.md` from this repository
3. Follow the process described in the skill exactly
4. Complete all verification steps before claiming done

### Skill Types

**Chain Skills** (drive the orchestration flow):
`brainstorming`, `writing-plans`, `subagent-driven-development`, `executing-plans`, `requesting-code-review`, `finishing-a-development-branch`

**Domain Skills** (auto-trigger during implementation):
`test-driven-development`, `incremental-implementation`, `api-and-interface-design`, `frontend-ui-engineering`, `security-and-hardening`, `performance-optimization`, `source-driven-development`, `code-simplification`, `documentation-and-adrs`, `browser-testing-with-devtools`

**Support Skills** (invoked by other skills):
`systematic-debugging`, `verification-before-completion`, `receiving-code-review`, `using-git-worktrees`, `dispatching-parallel-agents`, `context-engineering`, `writing-skills`

**Meta** (session routing):
`using-skills`

### Agents

The `agents/` directory contains subagent personas for specialized review:

| Agent | Purpose |
|-------|---------|
| `code-reviewer.md` | Senior Staff Engineer, 5-axis code review |
| `test-engineer.md` | QA Specialist, test strategy and coverage |
| `security-auditor.md` | Security Engineer, OWASP and threat modeling |

### References

The `references/` directory contains supplementary checklists:

| Reference | Use With |
|-----------|----------|
| `testing-patterns.md` | test-driven-development |
| `performance-checklist.md` | performance-optimization |
| `security-checklist.md` | security-and-hardening |
| `accessibility-checklist.md` | frontend-ui-engineering |

## Creating or Modifying Skills

### SKILL.md Format

```markdown
---
name: skill-name
description: One sentence describing when to use this skill. Include trigger phrases.
---

# Skill Title

## When to Use
Triggers and conditions

## Core Process
Step-by-step workflow

## Common Rationalizations
Excuses and rebuttals

## Red Flags
Signs the skill is being violated

## Verification
Exit criteria checklist
```

### Naming Conventions

- **Skill directory**: `kebab-case` (e.g., `test-driven-development`)
- **SKILL.md**: Always uppercase, always this exact filename
- Skills reference each other using `super-agent-skills:<skill-name>` namespace in Claude Code, or by bare name/path elsewhere

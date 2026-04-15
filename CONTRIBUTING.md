# Contributing to super-agent-skills

## Overview

super-agent-skills is a markdown-based Claude Code plugin. Contributing means writing or improving skill files, agent personas, reference guides, or commands. No traditional code — the "code" is the skill content itself.

## Quick Start

1. Clone the repo
2. Load as a local plugin: `claude --plugin-dir ./super-agent-skills`
3. Make changes
4. Test with `/reload-plugins`
5. Submit a PR

## Plugin Structure

```
skills/          29 skill directories, each with SKILL.md
agents/          7 agent persona .md files
references/      6 reference guide .md files
commands/        12 slash command .md files
hooks/           hooks.json + session-start.sh
```

See [docs/architecture.md](docs/architecture.md) for the complete process graph and skill inventory.

## Adding a New Skill

### 1. Create the directory and file

```bash
mkdir -p skills/my-new-skill
```

Create `skills/my-new-skill/SKILL.md` with this template:

```yaml
---
name: my-new-skill
description: One sentence. Include trigger phrases ("Use when..."). Under 250 characters.
---
```

### 2. Write the skill content

Every skill should include these sections:

| Section | Required | Purpose |
|---------|----------|---------|
| Overview | Yes | 1-2 sentences on what this skill does |
| When to Use | Yes | Bullet list of triggers |
| When NOT to Use | Yes | Prevent misapplication |
| Process / Workflow | Yes | Step-by-step instructions |
| Anti-Rationalizations | Yes | Table catching excuses to skip steps |
| Red Flags | Yes | Observable signs of violation |
| Verification | Yes | Checklist of exit criteria |

See [docs/skill-authoring-guide.md](docs/skill-authoring-guide.md) for the full guide with examples.

### 3. Add frontmatter fields

Add the custom capability fields to your skill's frontmatter:

```yaml
---
name: my-new-skill
description: "..."
phase: build                    # define|plan|build|verify|review|ship|support|meta
produces:
  - artifact-name               # what this skill outputs
chainsTo:
  - next-skill-name             # next skill in workflow (optional)
chainsFrom:
  - superthink                  # previous skill or entry point (optional)
autoTriggers:                   # contexts that auto-invoke this skill (optional)
  - "task involves X"
---
```

### 4. Run the build script

After editing any SKILL.md frontmatter, regenerate the capability index:

```bash
node scripts/generate-capability-index.js
```

This regenerates:
- `generated/session-start-capabilities.md` — companion tools table injected at session start
- `generated/routing-table.md` — skill routing table (also auto-updates `using-skills/SKILL.md`)
- `generated/when-to-use-suggestions.md` — review for description gaps

**Always commit the `generated/` files alongside your frontmatter changes.** End users don't run the build script — they use the committed generated files.

The script validates that all `chainsTo`/`chainsFrom` references point to existing skills and will error if a reference is broken.

### 5. Test

```bash
claude --plugin-dir ./super-agent-skills
/reload-plugins
```

Then try trigger phrases from your skill's description to verify Claude invokes it.

## Adding a New Agent

Create a file in `agents/` following the existing format:

```yaml
---
name: my-agent
description: What this agent does. Use for [specific scenarios].
---
```

Include: role definition, evaluation framework, output format template, rules.

See existing agents (e.g., `agents/code-reviewer.md`) for the pattern.

## Adding a New Command

Create a file in `commands/` following the existing format:

```yaml
---
description: What this command does
---

Invoke the `super-agent-skills:skill-name` skill.

[Instructions for Claude when this command is invoked]

Use argument if provided: $ARGUMENTS
```

## Modifying Existing Skills

- **Adding content** (new sections, new anti-rationalizations): usually safe, submit a PR
- **Changing behavior** (modifying process steps, altering handoffs): open an issue first to discuss
- **Changing frontmatter** (name, description): requires testing that routing still works

## Quality Checklist

Before submitting a PR, verify:

- [ ] Skill has valid YAML frontmatter (name, description, phase)
- [ ] Description includes trigger phrases and is under 250 characters
- [ ] `node scripts/generate-capability-index.js` runs without errors
- [ ] `generated/` files committed alongside frontmatter changes
- [ ] All standard sections present (overview, when to use, process, anti-rationalizations, red flags, verification)
- [ ] Anti-rationalization entries are specific (not generic "don't skip steps")
- [ ] Cross-references use `super-agent-skills:` namespace
- [ ] No stale `superpowers:` or `agent-skills:` references
- [ ] Tested with `/reload-plugins` and trigger phrases

## What NOT to Do

- Don't add skills that duplicate existing ones — check the [architecture](docs/architecture.md) first
- Don't modify the orchestration chain handoffs without discussion
- Don't add `disable-model-invocation: true` to skills (only to commands)
- Don't hardcode project-specific paths (keep skills generic)

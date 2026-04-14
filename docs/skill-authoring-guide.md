# Skill Authoring Guide

How to create, modify, and test skills for the super-agent-skills plugin.

## Skill Anatomy

Every skill is a directory containing `SKILL.md`:

```
skills/my-skill/
├── SKILL.md           # Main skill file (required)
├── reference.md       # Supporting file (optional)
└── scripts/           # Helper scripts (optional)
```

### SKILL.md Structure

```yaml
---
name: my-skill
description: What it does. Use when [trigger condition]. Under 250 chars.
---
```

Followed by markdown content with these standard sections:

### Required Sections

**1. Overview** (1-2 sentences)
```markdown
# My Skill

Brief description of what this skill does and why it exists.
```

**2. When to Use / When NOT to Use**
```markdown
## When to Use
- Trigger condition 1
- Trigger condition 2

**When NOT to use:** [conditions where this skill is wrong]
```

**3. Process / Workflow** (the core content)
```markdown
## The Process

### Step 1: [Action]
[Detailed instructions]

### Step 2: [Action]
[Detailed instructions]
```

**4. Anti-Rationalizations**
```markdown
## Anti-Rationalizations

| Thought | Reality |
|---------|---------|
| "[excuse to skip]" | [why the excuse is wrong] |
```

Write entries that are specific to THIS skill. "Don't skip steps" is too generic. "Requirements are obvious -> Unwritten requirements are unvalidated assumptions" is specific.

**5. Red Flags**
```markdown
## Red Flags
- Observable sign that the skill is being violated
- Another sign
```

**6. Verification**
```markdown
## Verification
- [ ] Concrete checkable criterion
- [ ] Another criterion
```

### Optional Sections

- **Examples** -- concrete code or workflow examples
- **Quick Reference** -- summary table for experienced users
- **Integration** -- which skills this works with
- **Supporting files** -- reference via `[text](filename.md)` in SKILL.md

## Writing Good Descriptions

The `description` field is critical -- Claude uses it to decide when to invoke the skill.

**Good:** `"Guides stable API and interface design. Use when designing APIs, module boundaries, or any public interface. Use when creating REST or GraphQL endpoints."`

**Bad:** `"API design skill"` (too vague, no trigger phrases)

**Rules:**
- Under 250 characters (truncated beyond that)
- Include "Use when..." trigger phrases
- Front-load the key use case
- Be specific enough that Claude doesn't invoke it for unrelated tasks

## Naming Conventions

- **Directory:** `kebab-case` (e.g., `my-new-skill`)
- **SKILL.md:** always uppercase, always this exact filename
- **Supporting files:** `kebab-case.md`
- **Name field:** matches directory name

## Cross-Referencing Other Skills

Always use the `super-agent-skills:` namespace:

```markdown
See `super-agent-skills:test-driven-development` for TDD guidance.
```

Never use bare names (`test-driven-development`) -- they won't resolve in the plugin system.

## Adding to the Routing Table

Update `skills/using-skills/SKILL.md` to include your skill in the routing tree:

```
    ├── [trigger question]? ──────────→ super-agent-skills:my-skill
```

Place it near related skills in the tree.

## Testing Your Skill

1. Load the plugin: `claude --plugin-dir ./super-agent-skills`
2. Run `/reload-plugins`
3. Try trigger phrases from your description
4. Verify Claude invokes your skill (not a different one)
5. Walk through the skill's process -- does each step make sense?
6. Check: would a fresh agent with no context follow these instructions correctly?

## Template

Copy this to start a new skill:

```yaml
---
name: my-skill
description: [What it does]. Use when [trigger 1]. Use when [trigger 2].
---

# My Skill

## Overview

[1-2 sentences]

## When to Use

- [Trigger condition]
- [Trigger condition]

**When NOT to use:** [Exclusion conditions]

## The Process

### Step 1: [Name]

[Instructions]

### Step 2: [Name]

[Instructions]

## Anti-Rationalizations

| Thought | Reality |
|---------|---------|
| "[Excuse]" | [Counter] |

## Red Flags

- [Sign of violation]

## Verification

- [ ] [Checkable criterion]
```

## Keep Skills Under 500 Lines

If a skill exceeds 500 lines, extract detailed content into supporting files:

```markdown
For detailed patterns, see [reference.md](reference.md).
```

Claude loads supporting files on demand -- they don't bloat every session.

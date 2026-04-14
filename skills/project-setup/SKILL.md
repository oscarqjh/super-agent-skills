---
name: project-setup
description: Scan a project and generate an effective CLAUDE.md. Use when starting work on a project that has no CLAUDE.md, or when the existing CLAUDE.md needs refreshing. Also handles organic growth — persisting corrections and gotchas over time.
disable-model-invocation: true
---

# Project Setup

Scan the current project and generate a lean, effective CLAUDE.md that helps Claude work better in this specific codebase. Less is more — a 50-line CLAUDE.md that Claude actually follows beats a 300-line one it ignores.

**Announce at start:** "I'm using project-setup to scan your project and generate a CLAUDE.md."

## The Golden Rule

For every line you generate, ask: **"Would removing this cause Claude to make a mistake?"**

If Claude would figure it out from the code anyway — don't include it. CLAUDE.md is for things Claude can't infer.

## What to Include vs Exclude

| Include (Claude can't infer) | Exclude (Claude can figure out) |
|------------------------------|--------------------------------|
| Non-obvious build/test/lint commands | Standard language conventions |
| Unconventional project structure | Obvious file organization |
| Environment quirks (required env vars, setup steps) | Framework defaults |
| Code conventions that differ from defaults | Things visible in config files |
| Common gotchas and non-obvious behaviors | File-by-file codebase descriptions |
| Architectural decisions not visible in code | Detailed API documentation |
| Branch naming / PR conventions | Standard git workflow |

## The Scan Process

### Step 1: Detect Tech Stack

Read project manifests to identify the stack:

```bash
# Check for project manifests (in order of priority)
cat package.json 2>/dev/null        # Node.js
cat requirements.txt 2>/dev/null     # Python
cat Cargo.toml 2>/dev/null           # Rust
cat go.mod 2>/dev/null               # Go
cat pom.xml 2>/dev/null              # Java
```

Extract: language, framework, key dependencies. Only note what's non-obvious.

### Step 2: Discover Commands

Find build/test/lint/dev commands:

```bash
# Check package.json scripts
cat package.json | jq '.scripts' 2>/dev/null

# Check for Makefile
cat Makefile 2>/dev/null | grep '^[a-z].*:' | head -10

# Check for justfile, taskfile, etc.
ls Makefile justfile Taskfile.yml .taskfile 2>/dev/null
```

Only include commands Claude can't guess. If the test command is `npm test`, skip it — Claude knows that. If it's `npm run test:unit -- --coverage --bail`, include it.

### Step 3: Detect Non-Obvious Conventions

Read 3-5 source files to spot patterns:

- Import style (named exports vs default, absolute vs relative paths)
- Component patterns (functional vs class, co-located tests vs separate)
- Naming conventions (if non-standard)
- Any `.eslintrc`, `.prettierrc`, `tsconfig.json` that enforce unusual rules

**Only note conventions that differ from language/framework defaults.** If a React project uses functional components — that's the default, skip it. If it uses class components — that's unusual, include it.

### Step 4: Check for Gotchas

Look for things that would trip Claude up:

```bash
# Monorepo?
ls packages/ apps/ modules/ 2>/dev/null

# Custom tooling?
ls scripts/ tools/ bin/ 2>/dev/null

# Environment requirements?
cat .env.example 2>/dev/null
cat .tool-versions 2>/dev/null
cat .nvmrc 2>/dev/null
```

Check git history for commit message conventions:
```bash
git log --oneline -10
```

### Step 5: Generate CLAUDE.md

Present a draft to the user. Target format:

```markdown
# Project: [name]

## Commands
- Build: `[only if non-obvious]`
- Test: `[only if non-obvious]`
- Lint: `[only if non-obvious]`
- Dev: `[only if non-obvious]`
- Type check: `[only if non-obvious]`

## Conventions
- [Only conventions that differ from defaults]
- [Only things Claude would get wrong without being told]

## Architecture
- [Only non-obvious structural decisions]
- [Only things not visible from reading the code]

## Boundaries
- Always: [project-specific musts]
- Ask first: [things that need human approval]
- Never: [hard rules]

## Gotchas
<!-- Add here when Claude makes wrong assumptions -->
```

**Target: under 100 lines.** If your draft is over 100 lines, you've included too much. Cut ruthlessly.

### Step 6: User Review

Present the draft and ask:

> "Here's the generated CLAUDE.md ([N] lines). Review it — I've tried to include only things I can't infer from the code. Want to add, remove, or change anything before I write it?"

Only write the file after user approval. If there's an existing CLAUDE.md, show a diff of what would change.

### Step 7: Suggest Rules Directory (for larger projects)

If the project is a monorepo or has >20 source directories, suggest path-scoped rules:

> "This project is large enough that path-scoped rules would help. Instead of putting everything in CLAUDE.md, I can create `.claude/rules/` files that only load when you're working in specific directories. Want me to set that up?"

If yes, create `.claude/rules/` with path-scoped rule files:

```markdown
# .claude/rules/api-conventions.md
---
paths: ["src/api/**", "src/routes/**"]
---
- All API endpoints use Zod validation at the route handler level
- Error responses use the AppError class from src/lib/errors.ts
```

## Organic Growth

### Persisting Corrections

When the user corrects you about a project convention during normal work (e.g., "No, we use pnpm here, not npm"), offer to persist it:

> "Got it — want me to add this to CLAUDE.md so I remember next time?"
>
> Proposed addition to ## Gotchas:
> `- Use pnpm, not npm (no package-lock.json in this project)`

If the user agrees, append the line to the Gotchas section of CLAUDE.md. If no Gotchas section exists, create one.

**This is a behavioral instruction for all skills, not just project-setup.** Any time Claude is corrected about something project-specific, it should offer to persist the correction.

### Auto-Detecting Failures

A PostToolUseFailure hook fires when commands fail. The hook prompts Claude to consider whether the failure was caused by a project-specific convention that should be recorded:

```json
"PostToolUseFailure": [
  {
    "matcher": "Bash",
    "hooks": [
      {
        "type": "prompt",
        "prompt": "A command failed. If this failure was caused by a project-specific convention, setup requirement, or non-obvious configuration that Claude should know about for future sessions, suggest adding a rule to CLAUDE.md's Gotchas section. Only suggest this if the failure reveals something non-obvious — don't suggest adding rules for typos or standard errors."
      }
    ]
  }
]
```

This creates a feedback loop: failures → rules → fewer failures.

## When NOT to Use

- Project already has a comprehensive CLAUDE.md — offer to audit instead of replace
- Temporary/throwaway project — not worth the setup
- Project is a single file — CLAUDE.md would be longer than the project

## Anti-Rationalizations

| Thought | Reality |
|---------|---------|
| "I'll add everything just in case" | More rules = more ignored rules. Every unnecessary line dilutes the important ones. |
| "Claude needs to know the full architecture" | Claude can read the code. It needs to know what the code doesn't tell it. |
| "I'll generate it once and forget it" | CLAUDE.md should grow organically. The Gotchas section is where the real value accumulates. |
| "This project is too simple for CLAUDE.md" | Even 5 lines (commands + one gotcha) save time across sessions. |

## Red Flags

- Generated CLAUDE.md over 100 lines — too verbose, cut ruthlessly
- Including standard conventions (functional components, ES modules) that Claude knows
- Including file-by-file descriptions of the codebase
- No Gotchas section — this is where organic growth happens
- Never updating CLAUDE.md after generating it — it should be a living document

## Verification

After generating CLAUDE.md:

- [ ] File is under 100 lines
- [ ] Every line passes the "would removing this cause a mistake?" test
- [ ] Commands section only has non-obvious commands
- [ ] Conventions section only has things that differ from defaults
- [ ] Gotchas section exists (even if empty) for organic growth
- [ ] User has reviewed and approved the content

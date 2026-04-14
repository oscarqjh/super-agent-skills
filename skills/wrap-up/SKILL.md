---
name: wrap-up
description: Lightweight end-of-phase checkpoint. Use after completing a task or feature to update backlog, changelog, commit, and move to the next item. For branch-based workflows with merge/PR, use finishing-a-development-branch instead.
---

# Wrap Up

Lightweight checkpoint for completing a phase of work. Updates tracking artifacts, commits, and moves on.

**Use this when:** you're working on a single branch (main or dev) and want to checkpoint your progress — update backlog, changelog, commit, and pick the next task.

**Use `super-agent-skills:finishing-a-development-branch` instead when:** you're on a feature branch and need to merge/PR back to the base branch, or you're using git worktrees.

**Announce at start:** "I'm using the wrap-up skill to checkpoint this work."

## The Process

### Step 1: Verify Clean State

Before wrapping up, verify:

```bash
# Tests pass (if applicable)
<project test command>

# No uncommitted work that should be included
git status
```

If tests fail or there's unfinished work, fix it before continuing.

### Step 2: Update Backlog

Read `docs/super-agent-skills/backlogs.md`:

1. Mark any related "In Progress" items as complete (`[x]`)
2. Move completed items to the "Completed" section with today's date
3. If "In Progress" is now empty, note what's next from "Up Next"

### Step 3: Update Changelog

Read `docs/super-agent-skills/changelog.md`:

1. Under `[Unreleased]`, append a one-line description of what was completed
2. Follow the Keep a Changelog format (Added/Changed/Fixed/Removed)

### Step 4: Update Docs (if needed)

Check if any of these need updating:
- README.md — if new features were added that users need to know about
- CLAUDE.md — if conventions or structure changed
- Setup guides — if installation or configuration changed

Skip if no docs changes are needed. Don't create busywork.

### Step 5: Commit

Review what will be committed first:

```bash
git status
git diff --staged
```

Stage relevant files and commit:

```bash
git add <specific files>
git commit -m "<type>: <description of what was completed>"
```

Use conventional commit types: feat, fix, refactor, docs, chore.

### Step 6: Capture Learnings

Before moving on, reflect on this work phase:

| Question | If yes → |
|----------|----------|
| Did the user correct you about a convention? | Add to CLAUDE.md `## Gotchas` |
| Did a command fail due to project-specific setup? | Add to CLAUDE.md `## Commands` |
| Did the code reviewer flag a pattern violation? | Add to `.claude/rules/` as a path-scoped rule |
| Did the self-healing review loop hit 3 rounds? | Note that the spec/plan was ambiguous — add clarity for next time |
| Did you make the same mistake twice in this session? | Add to CLAUDE.md `## Gotchas` (high priority — this will recur) |

If any apply, offer to persist:

> "I noticed [learning]. Want me to add this to CLAUDE.md so I remember next time?"

Only persist things Claude would get wrong without being told. Don't add obvious conventions Claude already knows.

### Step 7: Suggest Next

> "Wrapped up: [what was completed]. Next in backlog: [next item from Up Next]. Want to start on it?"

If the user says yes, invoke `super-agent-skills:brainstorming` (for new features) or the appropriate skill for the next item.

## When NOT to Use

- You're on a feature branch that needs to merge → use `super-agent-skills:finishing-a-development-branch`
- You're in the middle of implementation (not at a checkpoint) → keep working
- There's nothing to commit → skip wrap-up

## Anti-Rationalizations

| Thought | Reality |
|---------|---------|
| "I'll update the backlog later" | Later never comes. Update it now while the context is fresh. |
| "The changelog isn't important" | Future you won't remember what changed. One line now saves 10 minutes of git log archaeology later. |
| "I'll just commit without wrapping up" | A commit without backlog/changelog update breaks the tracking chain. Take 30 seconds to update both. |

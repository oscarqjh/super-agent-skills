---
name: compound-engineering
description: "Executes multi-stream parallel feature development across isolated worktrees. Use when writing-plans detects 2+ independent work streams in the plan and the user chooses compound execution at the handoff."
phase: build
produces:
  - multi-stream-code
chainsTo:
  - requesting-code-review
chainsFrom:
  - writing-plans
---

# Compound Engineering

Execute independent work streams in parallel across isolated worktrees, then integrate the results.

**Prerequisite:** `super-agent-skills:writing-plans` has already written the plan, detected independent streams, and the user chose compound execution. You receive the stream grouping (which tasks belong to which stream) and integration points (shared types, API contracts).

**Announce at start:** "I'm using compound-engineering to orchestrate parallel work streams."

## Before Execution

Verify the stream grouping from writing-plans:

1. **Confirm independence** — can each stream be built and tested without the others?
2. **Define contracts** — if streams share interfaces (API schemas, type definitions, shared models), define them before splitting. Commit contract files to the base branch first.
3. **Max 3 streams** — if more, merge the smallest streams until ≤3

## Execute in Parallel

For each stream:

1. **Create an isolated worktree** using `super-agent-skills:using-git-worktrees`
2. **Dispatch `super-agent-skills:subagent-driven-development`** in each worktree with the stream's tasks from the plan
3. Streams execute in parallel — each with its own task cycle, reviews, and commits

```
main branch
  ├── worktree: feature/sharing-backend   ← Stream A executing
  ├── worktree: feature/sharing-frontend  ← Stream B executing
  └── worktree: feature/sharing-notifs    ← Stream C executing
```

## Integrate

After all streams complete:

1. **Merge streams sequentially** — merge Stream A to main, then Stream B, then Stream C
2. **Resolve conflicts** — if streams touched shared files (despite planning), resolve now
3. **Run full test suite** — all tests from all streams must pass together
4. **Integration testing** — test cross-stream connections (API contract adherence, end-to-end flows)
5. **If integration fails** — identify which stream's changes caused the failure, fix in that stream's context

## Review

Invoke `super-agent-skills:requesting-code-review` on the combined result. The chain then continues normally: requesting-code-review → user prompt → wrap-up or ship.

## Safety Rules

- **Sequential streams are fine** — if Stream B depends on Stream A, run A first, then B
- **Integration testing is mandatory** — parallel work may produce individually correct but collectively broken code
- Streams sharing >30% of files are too coupled — should be a single stream

## Red Flags

- No shared contract committed before streams split
- Streams that can't be tested independently
- More than 3 parallel streams

## Verification

After integration:

- [ ] All streams merged to main
- [ ] Full test suite passes (not just per-stream tests)
- [ ] Integration tests verify cross-stream connections
- [ ] No merge conflicts left unresolved

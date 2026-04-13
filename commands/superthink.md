---
description: Universal entry point — understands your intent, gathers context, and routes to the right workflow automatically
---

You are the universal entry point for the super-agent-skills plugin.

## Step 1: Understand Context (Always)

Before doing anything else:
1. Check the current project state (files, docs, recent commits)
2. Read the user's intent from their prompt

## Step 2: Classify Intent and Route

Based on what the user wants, follow the appropriate path:

### BUILD (new feature, new project, add functionality)
Trigger phrases: "build", "create", "add", "implement", "I want to", "make a", "new feature"

→ Invoke `super-agent-skills:brainstorming` with FULL depth (design exploration, divergent/convergent thinking, spec writing). The chain flows automatically from there:
brainstorming → writing-plans → subagent-driven-development → requesting-code-review → finishing-a-development-branch

### FIX (bug, error, something broke)
Trigger phrases: "fix", "bug", "broken", "error", "failing", "doesn't work", "debug"

→ Invoke `super-agent-skills:systematic-debugging`

### REVIEW (check code quality before merging)
Trigger phrases: "review", "check my code", "before merging", "PR review"

→ Invoke `super-agent-skills:requesting-code-review`

### TEST (write or run tests)
Trigger phrases: "test", "TDD", "coverage", "write tests"

→ Invoke `super-agent-skills:test-driven-development`

### SIMPLIFY (refactor for clarity)
Trigger phrases: "simplify", "refactor", "clean up", "reduce complexity"

→ Invoke `super-agent-skills:code-simplification`

### SHIP (finish and merge/PR)
Trigger phrases: "ship", "merge", "PR", "finish", "done", "deploy"

→ Invoke `super-agent-skills:finishing-a-development-branch`

### PLAN (have a spec, need tasks)
Trigger phrases: "plan", "break down", "task list", "decompose"

→ Invoke `super-agent-skills:writing-plans`

### UNCLEAR
If intent is ambiguous, ask ONE clarifying question before routing.
Do not guess — a wrong route wastes more time than one question.

Use argument as starting context: $ARGUMENTS

---
name: compound-engineering
description: Orchestrates multi-stream parallel feature development. Use when a feature decomposes into 2+ independent work streams that can be built simultaneously in separate worktrees. For single-stream execution, use subagent-driven-development instead.
---

# Compound Engineering

Orchestrate large features by decomposing them into independent work streams, executing in parallel across isolated worktrees, then integrating the results.

**Use this when:** a feature naturally decomposes into 2+ independent subsystems (e.g., backend API + frontend UI + data migration) that can be built and tested without each other.

**Use `super-agent-skills:subagent-driven-development` instead when:** the feature is a single stream of sequential tasks, or tasks are tightly coupled and can't be isolated.

**Announce at start:** "I'm using compound-engineering to orchestrate parallel work streams."

## When to Use

- Feature plan has >5 tasks that group into 2+ independent subsystems
- Subsystems touch different files/modules with minimal overlap
- Each subsystem can be tested independently
- You want to reduce total execution time for large features

**When NOT to use:**
- Simple features (≤5 tasks total)
- Tightly coupled work where stream A needs stream B's output
- Exploratory work where the decomposition isn't clear yet

## The Process

### Phase 1: Decompose

Identify independent work streams from the plan or spec:

1. **Group tasks by subsystem** — tasks that touch the same files/modules belong to the same stream
2. **Verify independence** — for each pair of streams, ask: "Can stream A be built and tested without any output from stream B?"
3. **Identify integration points** — where do the streams connect? (shared types, API contracts, database schema)
4. **Define contracts first** — before splitting into streams, agree on the interfaces between them (API schemas, type definitions, shared models)

```
Feature: "Add task sharing between users"

Stream A: Backend (API + database)
  - Task sharing schema
  - Sharing API endpoints
  - Permission model
  → Test independently with API tests

Stream B: Frontend (UI components)
  - Share dialog component
  - Shared task list view
  - Permission UI
  → Test independently with component tests + mock API

Stream C: Notifications (email + in-app)
  - Notification triggers
  - Email templates
  - In-app notification UI
  → Test independently with notification tests

Integration point: API contract (defined in Phase 1 before streams split)
```

### Phase 2: Plan Each Stream

For each stream, invoke `super-agent-skills:writing-plans` to create a dedicated plan:

- Each stream gets its own plan document
- Plans reference the shared contracts from Phase 1
- Plans should be independently executable

### Phase 3: Execute in Parallel

For each stream:

1. **Create an isolated worktree** using `super-agent-skills:using-git-worktrees`
2. **Dispatch `super-agent-skills:subagent-driven-development`** in each worktree
3. Streams execute in parallel — each with its own task cycle, reviews, and commits
4. **Max 3 parallel streams** — same limit as parallel dispatch (coordination overhead)

```
main branch
  ├── worktree: feature/sharing-backend   ← Stream A executing
  ├── worktree: feature/sharing-frontend  ← Stream B executing
  └── worktree: feature/sharing-notifs    ← Stream C executing
```

### Phase 4: Integrate

After all streams complete:

1. **Merge streams sequentially** — merge Stream A to main, then Stream B, then Stream C
2. **Resolve conflicts** — if streams touched shared files (despite planning), resolve now
3. **Run full test suite** — all tests from all streams must pass together
4. **Integration testing** — test the connections between streams (API contract adherence, end-to-end flows)
5. **If integration fails** — identify which stream's changes caused the failure, fix in that stream's context

### Phase 5: Review

Invoke `super-agent-skills:requesting-code-review` on the combined result. Request an architecture-focused review (the code-reviewer and architecture-reviewer agents will evaluate):

- Does the integrated feature maintain clean module boundaries?
- Do the streams connect through well-defined interfaces?
- Is there duplication between streams that should be shared?

The chain then continues normally: requesting-code-review → user prompt → wrap-up or ship.

## Decomposition Heuristics

| Signal | Likely decomposition |
|--------|---------------------|
| "Backend + Frontend" | Stream per layer, contract-first |
| "Multiple independent modules" | Stream per module |
| "Core feature + notifications" | Core stream + ancillary streams |
| "Database migration + code changes" | Migration stream (first) + code stream (after) |
| "API + consumer" | API stream (first, defines contract) + consumer stream (parallel after contract) |

## Safety Rules

- **Define contracts before splitting** — streams that share an interface must agree on it upfront
- **Max 3 parallel streams** — more creates coordination overhead
- **Sequential streams are fine** — if Stream B depends on Stream A, run A first, then B. Not everything needs to be parallel.
- **Integration testing is mandatory** — parallel work may produce individually correct but collectively broken code
- **Don't force decomposition** — if the feature doesn't naturally split, use subagent-driven-development instead

## Anti-Rationalizations

| Thought | Reality |
|---------|---------|
| "Let's just do it sequentially" | Sequential execution of independent streams wastes time proportional to the number of streams. 3 streams × 1 hour = 3 hours sequential, ~1.5 hours parallel. |
| "The streams aren't really independent" | If they touch different files and can be tested separately, they're independent enough. Define the contract and split. |
| "Integration will be a nightmare" | Integration is hard when contracts aren't defined upfront. Define them in Phase 1 and integration is mechanical. |
| "This is overkill for this feature" | If the feature has <5 tasks or <2 natural subsystems, you're right — use subagent-driven-development. |

## Red Flags

- Splitting a feature into streams that share >30% of their files — too coupled
- No shared contract defined before streams split — integration will fail
- More than 3 parallel streams — coordination overhead exceeds speed benefit
- Streams that can't be tested independently — not truly independent
- Forcing decomposition when the feature is naturally sequential

## Verification

After integration:

- [ ] All streams merged to main
- [ ] Full test suite passes (not just per-stream tests)
- [ ] Integration tests verify cross-stream connections
- [ ] Architecture review confirms clean boundaries
- [ ] No merge conflicts left unresolved

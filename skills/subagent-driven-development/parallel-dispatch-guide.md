# Parallel Dispatch Guide

Detailed guidance for dispatching multiple implementer subagents simultaneously.

## When to Use Parallel Dispatch

Use parallel dispatch when:
- The plan has 2+ tasks with zero file overlap
- Tasks are independent (no dependency between them)
- You want to reduce total execution time

Do NOT use when:
- Tasks share any files (even test files)
- Tasks have logical dependencies (Task B needs Task A's output)
- The plan is small (3 or fewer total tasks — overhead isn't worth it)

## The File Overlap Algorithm

```
function canParallelize(taskA, taskB):
  filesA = taskA.create + taskA.modify + taskA.test
  filesB = taskB.create + taskB.modify + taskB.test
  return intersection(filesA, filesB) == empty
```

### Example: 5-Task Plan

```
Task 1: DB schema migration          → files: db/migrations/001.sql, db/schema.ts
Task 2: API endpoint for tasks        → files: src/api/tasks.ts, tests/api/tasks.test.ts
Task 3: API endpoint for users        → files: src/api/users.ts, tests/api/users.test.ts
Task 4: UI component for task list    → files: src/components/TaskList.tsx, tests/components/TaskList.test.tsx
Task 5: Wire UI to API               → files: src/api/tasks.ts, src/components/TaskList.tsx

Dependency analysis:
- Task 1 must be first (schema is foundation)
- Task 2 and Task 3: zero overlap → PARALLEL BATCH A
- Task 4: zero overlap with 2 and 3 → add to BATCH A (3 agents max)
- Task 5: overlaps with Task 2 (tasks.ts) and Task 4 (TaskList.tsx) → SEQUENTIAL after batch

Execution order:
  Sequential: Task 1
  Parallel:   Task 2 + Task 3 + Task 4 (Batch A)
  Sequential: Task 5
```

## Batch Review Process

After a parallel batch completes:

1. **Check all agents completed successfully** — if any BLOCKED, resolve before reviewing
2. **Run spec compliance on each** — reviewer sees the combined codebase state
3. **Fix issues one task at a time** — fixes after parallel work must be sequential
4. **Run full test suite** — catches integration issues between parallel changes
5. **Only then proceed** to the next batch or task

## Handling Failures in a Batch

| Scenario | Action |
|----------|--------|
| One agent BLOCKED | Pause batch. Resolve blocker. Re-dispatch that agent only. |
| One agent NEEDS_CONTEXT | Provide context. Re-dispatch that agent. Others continue. |
| One agent DONE_WITH_CONCERNS | Note concerns. Proceed to review. Address in review if needed. |
| Integration tests fail after batch | Identify which task's changes caused failure. Fix sequentially. |

## Anti-Rationalizations

| Thought | Reality |
|---------|---------|
| "These tasks probably don't overlap" | Check the files. "Probably" is not a safety gate. |
| "We can handle merge conflicts" | Prevention is cheaper than resolution. Stay sequential if there's overlap. |
| "Let's parallelize everything for speed" | Parallel dispatch is an optimization for independent tasks. Dependent tasks parallelized produce bugs. |

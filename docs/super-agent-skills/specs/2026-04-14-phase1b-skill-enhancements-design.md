# Phase 1B: Skill Enhancements — Parallel Execution, Test Generation, Architecture Review

## Objective

Enhance 3 existing skills with capabilities that change core workflow behavior. These are the more complex enhancements from Phase 1 that modify skill flow, not just add sections.

**Success criteria:**
- subagent-driven-development can dispatch independent tasks in parallel (up to 3) with file overlap safety gate
- test-driven-development generates full test implementations from spec acceptance criteria before the RED phase
- requesting-code-review has strengthened architecture evaluation, automated fix-and-re-review loop (up to 3 rounds), and hard sizing gate

## Tech Stack

Markdown authoring only. No code, no scripts.

## Files to Modify

| File | Change type | Estimated additions |
|------|------------|-------------------|
| `skills/subagent-driven-development/SKILL.md` | Add "Parallel Dispatch" section, update Red Flags, update process flow | ~40 lines |
| `skills/subagent-driven-development/parallel-dispatch-guide.md` | NEW file — detailed parallel dispatch algorithm and examples | ~80 lines |
| `skills/test-driven-development/SKILL.md` | Add "Spec-Driven Test Generation" section with bulk RED phase | ~50 lines |
| `skills/requesting-code-review/SKILL.md` | Strengthen architecture axis, add self-healing review loop, add sizing gate | ~60 lines |

---

## Enhancement 1.1: Selective Parallel Execution

### Changes to subagent-driven-development/SKILL.md

**After the existing "Implementer Dispatch" section (which covers implementer instructions and domain auto-triggers), add:**

```markdown
## Parallel Dispatch

When the plan contains independent tasks (no shared files), dispatch them simultaneously for faster execution.

### File Overlap Check

Before dispatching the next batch of tasks, check for file overlap:

1. Read the "Files" section of each upcoming task
2. Build a set of all files each task will touch (create + modify + test)
3. If any two tasks share ANY file → those tasks must stay sequential
4. Tasks with zero overlap can be dispatched in parallel

```
Task 3: Files: src/api/tasks.ts, tests/api/tasks.test.ts
Task 4: Files: src/components/TaskList.tsx, tests/components/TaskList.test.tsx
Task 5: Files: src/api/tasks.ts, src/api/auth.ts

→ Task 3 and Task 4: zero overlap → PARALLEL
→ Task 5 shares src/api/tasks.ts with Task 3 → SEQUENTIAL (after Task 3)
```

### Parallel Batch Execution

1. Group overlapping-free tasks into a batch (max 3 agents)
2. Dispatch all agents in the batch simultaneously using background mode
3. Wait for all to complete
4. Run spec compliance review on each result (sequentially — reviewer needs to see combined state)
5. Run code quality review on each result
6. Fix issues sequentially (fixes may now touch shared areas)
7. Run full test suite after the batch to catch integration issues

### Safety Rules

- **Max 3 parallel agents** — more creates coordination overhead that exceeds the speed benefit
- **ANY shared file → sequential** — no exceptions, even if the changes are in different functions
- **BLOCKED/NEEDS_CONTEXT in batch → pause all** — resolve the blocker before continuing
- **Post-batch test suite is mandatory** — parallel work may have integration issues that per-task tests miss
- **When in doubt, stay sequential** — parallel dispatch is an optimization, not a requirement

For detailed algorithm and examples, see `parallel-dispatch-guide.md`.
```

**Update the Red Flags section:**

Replace:
```
- Dispatch multiple implementation subagents in parallel (conflicts)
```

With:
```
- Dispatch parallel subagents without verifying zero file overlap between tasks (see Parallel Dispatch)
- Dispatch more than 3 parallel subagents simultaneously
```

**Update the process flow graphviz diagram:**

After the "More tasks remain?" node, add an alternative path:

```
"More tasks remain?" -> "Check file overlap for next N tasks" [label="yes"];
"Check file overlap for next N tasks" -> "Dispatch parallel batch (max 3)" [label="no overlap"];
"Check file overlap for next N tasks" -> "Dispatch implementer subagent (./implementer-prompt.md)" [label="overlap found"];
"Dispatch parallel batch (max 3)" -> "Review each result sequentially";
"Review each result sequentially" -> "Run integration test suite";
"Run integration test suite" -> "More tasks remain?";
```

### New file: skills/subagent-driven-development/parallel-dispatch-guide.md

```markdown
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
```

---

## Enhancement 1.2: Spec-Driven Test Generation

### Changes to test-driven-development/SKILL.md

**After the existing "When to Use" / "When NOT to use" section and before "The TDD Cycle", add:**

```markdown
## Spec-Driven Test Generation

When acceptance criteria or Given/When/Then test skeletons exist in the spec (generated by the brainstorming skill), generate the full test implementations BEFORE starting the TDD cycle. This is a "bulk RED" phase — all tests are written first, all should fail, then you make them pass one at a time.

### When to Generate

- The plan task includes explicit acceptance criteria
- The spec has an "Acceptance Tests" section with Given/When/Then skeletons
- You're implementing a well-specified feature (not exploratory work)

**Skip generation when:** Requirements are vague, you're doing exploratory/spike work, or the task is a single-function bug fix (use the Prove-It Pattern instead).

### The Generation Process

1. **Read acceptance criteria** from the spec or plan task
2. **Generate concrete test implementations** — not skeletons, but actual runnable tests:

```typescript
// From spec: "test: user can create a task with title and description"
//   Given: authenticated user
//   When: POST /api/tasks with {title: "Buy milk", description: "2%"}
//   Then: 201 response with task ID, task appears in GET /api/tasks

describe('POST /api/tasks', () => {
  it('creates a task with title and description', async () => {
    const auth = await loginAsTestUser();
    
    const response = await request(app)
      .post('/api/tasks')
      .set('Authorization', `Bearer ${auth.token}`)
      .send({ title: 'Buy milk', description: '2%' });

    expect(response.status).toBe(201);
    expect(response.body.id).toBeDefined();
    expect(response.body.title).toBe('Buy milk');

    // Verify persistence
    const tasks = await request(app)
      .get('/api/tasks')
      .set('Authorization', `Bearer ${auth.token}`);
    expect(tasks.body).toContainEqual(
      expect.objectContaining({ title: 'Buy milk' })
    );
  });
});
```

3. **Generate edge case tests** beyond what the spec lists. For each function/endpoint, consider:

| Category | Test cases |
|----------|-----------|
| Empty/null inputs | null, undefined, empty string, empty array |
| Boundary values | 0, -1, MAX_INT, max length string |
| Invalid types | string where number expected, object where string expected |
| Auth/access | unauthenticated, wrong user, expired token |
| Duplicate/conflict | creating something that already exists |
| Concurrent access | two simultaneous requests modifying the same resource |

4. **Run all generated tests** — they should ALL FAIL (they test code that doesn't exist yet)
5. **Proceed with normal TDD** — each failing test becomes a RED target. Make them pass one at a time.

### Bulk RED → Incremental GREEN

```
BULK RED:
  Generate all tests from spec → Run → All FAIL (good)

INCREMENTAL GREEN:
  Pick test 1 → Write minimal code → PASS → Commit
  Pick test 2 → Write minimal code → PASS → Commit
  Pick test 3 → Write minimal code → PASS → Commit
  ...
  All tests PASS → REFACTOR → Done
```

This is NOT "write all code at once." You still implement incrementally — the only difference is that the tests exist upfront instead of being invented one at a time.
```

---

## Enhancement 1.5: Architecture Review + Self-Healing Loop

### Changes to requesting-code-review/SKILL.md

**(A) Strengthen the Architecture axis.**

In "### 3. Architecture", replace the existing 4 bullets with this expanded list:

```markdown
### 3. Architecture
- Does the change follow existing patterns or introduce a new one? If new, is it justified?
- Does it maintain clean module boundaries?
- Is there code duplication that should be shared?
- Are dependencies flowing in the right direction (no circular dependencies)?
- Does this change increase or decrease coupling between modules?
- Are new abstractions justified by multiple use cases (not speculative)?
- Could this change break consumers of the modified interfaces (Hyrum's Law)?
- Is the dependency graph acyclic? Does this change introduce cycles?
- For new public APIs: is the interface minimal? Could it be made smaller?
```

**(B) Add "Self-Healing Review Loop" section.**

After the "Domain Skill Sub-Checks" section and before "Integration with Workflows", add:

```markdown
## Self-Healing Review Loop

When the reviewer finds Critical or Important issues, automate the fix-and-re-review cycle instead of manual back-and-forth.

### The Loop

```
Reviewer returns issues
    │
    ├── Critical/Important issues found
    │   │
    │   ▼
    │   Dispatch fix agent with reviewer feedback as instructions
    │   │
    │   ▼
    │   Fix agent makes changes and commits
    │   │
    │   ▼
    │   Re-dispatch reviewer to verify fixes
    │   │
    │   ├── Issues resolved → Proceed
    │   └── Issues remain → Loop (max 3 rounds)
    │
    ├── Only Minor/Nit issues → Proceed (note for later)
    │
    └── No issues → Proceed
```

### Rules

- **Max 3 rounds.** If the issue isn't fixed after 3 review-fix cycles, escalate to human. Three rounds of the same issue means the problem is in the spec or architecture, not the implementation.
- **Fix agent gets the reviewer's exact feedback** — file:line references, what's wrong, how to fix. No guessing.
- **Each round re-reviews only the fix** — don't re-review the entire change from scratch.
- **Track the loop count.** If a project consistently hits 3 rounds, the plans need more detail or the acceptance criteria are ambiguous.

### Anti-Rationalizations

| Thought | Reality |
|---------|---------|
| "The fix is obvious, skip re-review" | Obvious fixes introduce obvious bugs. Re-review is cheap. |
| "3 rounds is too many, just merge" | 3 rounds means the spec is broken. Merging broken code is more expensive. |
| "I'll fix it manually instead of dispatching" | Manual fixes pollute your context. Dispatch a fresh agent. |
```

**(C) Add "Review Sizing Gate" section.**

After "Change Sizing", add:

```markdown
## Review Sizing Gate

Before dispatching the reviewer, enforce the sizing rules as a hard gate:

```bash
# Count lines changed
LINES_CHANGED=$(git diff --stat $BASE_SHA..$HEAD_SHA | tail -1 | awk '{print $4+$6}')
```

| Lines changed | Action |
|---------------|--------|
| ≤300 | Proceed with review |
| 301-1000 | Warn: "This change is large. Consider splitting." Proceed if author confirms. |
| >1000 | Block: "This change is too large to review effectively. Split it before requesting review." Do NOT dispatch reviewer. |

This enforces what "Change Sizing" recommends. A 2000-line review catches fewer bugs than two 1000-line reviews because reviewer attention degrades with size.
```

---

## Boundaries

- **Always:** Keep new content consistent with existing skill voice and structure
- **Always:** New flow changes are additive — existing sequential flow still works
- **Never:** Break the existing sequential dispatch (parallel is an optional optimization)
- **Never:** Auto-merge without review (self-healing loop still requires reviewer approval)
- **Ask first:** If a skill exceeds 500 lines after additions, extract to supporting file

## Testing Strategy

Verification checklist:

- [ ] Each modified SKILL.md has valid YAML frontmatter after changes
- [ ] parallel-dispatch-guide.md referenced correctly from subagent-driven-development SKILL.md
- [ ] Red Flags update doesn't break existing list structure
- [ ] Test generation section flows naturally before the TDD cycle
- [ ] Self-healing loop diagram is consistent with existing review flow
- [ ] Review sizing gate commands use correct git diff syntax
- [ ] No stale `superpowers:` references
- [ ] All skill cross-references use `super-agent-skills:` namespace

## Acceptance Tests

Generated from success criteria:

- [ ] `test: subagent-driven-development contains parallel dispatch section`
      Given: the modified SKILL.md
      When: searching for "Parallel Dispatch" heading
      Then: section exists with file overlap check, batch execution, safety rules

- [ ] `test: parallel dispatch has safety gate`
      Given: the parallel dispatch section
      When: reading safety rules
      Then: max 3 agents rule exists, ANY shared file → sequential rule exists, post-batch test suite mandatory

- [ ] `test: red flags updated correctly`
      Given: the modified Red Flags section
      When: searching for old "Dispatch multiple implementation subagents in parallel"
      Then: old text replaced with new overlap-aware text

- [ ] `test: TDD has spec-driven test generation`
      Given: the modified TDD SKILL.md
      When: searching for "Spec-Driven Test Generation" heading
      Then: section exists with generation process, edge case table, bulk RED flow

- [ ] `test: requesting-code-review has expanded architecture axis`
      Given: the modified architecture review section
      When: counting bullet points in "### 3. Architecture"
      Then: 9 bullets (was 4)

- [ ] `test: self-healing review loop exists`
      Given: the modified requesting-code-review SKILL.md
      When: searching for "Self-Healing Review Loop"
      Then: section exists with loop diagram, 3-round max rule, anti-rationalizations

- [ ] `test: review sizing gate enforced`
      Given: the modified requesting-code-review SKILL.md
      When: searching for "Review Sizing Gate"
      Then: section exists with line count thresholds (≤300, 301-1000, >1000)

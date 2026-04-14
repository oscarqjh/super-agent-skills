# Phase 1B Skill Enhancements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use super-agent-skills:subagent-driven-development (recommended) or super-agent-skills:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enhance 3 existing skills with parallel execution, spec-driven test generation, and architecture review improvements.

**Architecture:** Additive changes to existing SKILL.md files plus one new supporting file. Each enhancement is independent — no shared files between tasks.

**Tech Stack:** Markdown authoring. No code or scripts.

**If the spec includes an "Acceptance Tests" section** (generated during brainstorming), incorporate those test skeletons into the plan's task steps. Each acceptance test should map to a specific task's test step — don't make the implementer re-derive tests that already exist in the spec.

---

## Source Paths

```
PLUGIN = /mnt/umm/users/qianjianheng/workspace/super-agent-skills
SPEC   = docs/specs/2026-04-14-phase1b-skill-enhancements-design.md
```

---

### Task 1: Create parallel-dispatch-guide.md supporting file

**Files:**
- Create: `skills/subagent-driven-development/parallel-dispatch-guide.md`

- [ ] **Step 1: Create the supporting file**

Write `skills/subagent-driven-development/parallel-dispatch-guide.md` with this content:

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

- [ ] **Step 2: Verify file created**

```bash
wc -l skills/subagent-driven-development/parallel-dispatch-guide.md
head -3 skills/subagent-driven-development/parallel-dispatch-guide.md
```

Expected: ~70-80 lines, starts with `# Parallel Dispatch Guide`.

- [ ] **Step 3: Commit**

```bash
git add skills/subagent-driven-development/parallel-dispatch-guide.md
git commit -m "feat: add parallel dispatch guide for subagent-driven-development"
```

---

### Task 2: Add parallel dispatch to subagent-driven-development skill

**Files:**
- Modify: `skills/subagent-driven-development/SKILL.md`

- [ ] **Step 1: Read the current file**

Read `skills/subagent-driven-development/SKILL.md` to find:
1. The "Implementer Dispatch" section (add new section after it)
2. The "Red Flags" section (update the parallel dispatch bullet)
3. The process flow graphviz diagram (add parallel path)

- [ ] **Step 2: Add "Parallel Dispatch" section**

After the "Implementer Dispatch" section (which ends with the domain auto-trigger list), add:

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

1. Group overlap-free tasks into a batch (max 3 agents)
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

- [ ] **Step 3: Update Red Flags**

In the "Red Flags" section under "**Never:**", find:

```
- Dispatch multiple implementation subagents in parallel (conflicts)
```

Replace with:

```
- Dispatch parallel subagents without verifying zero file overlap between tasks (see Parallel Dispatch)
- Dispatch more than 3 parallel subagents simultaneously
```

- [ ] **Step 4: Update process flow diagram**

In the graphviz `digraph process`, find the edge:

```
"More tasks remain?" -> "Dispatch implementer subagent (./implementer-prompt.md)" [label="yes"];
```

Replace with:

```
"More tasks remain?" -> "Check file overlap\nfor next N tasks" [label="yes"];
"Check file overlap\nfor next N tasks" -> "Dispatch parallel batch\n(max 3 agents)" [label="no overlap"];
"Check file overlap\nfor next N tasks" -> "Dispatch implementer subagent (./implementer-prompt.md)" [label="overlap found\nor single task"];
"Dispatch parallel batch\n(max 3 agents)" -> "Review each result\nsequentially" [label="all complete"];
"Review each result\nsequentially" -> "Run integration\ntest suite";
"Run integration\ntest suite" -> "More tasks remain?";
```

Also add the new node declarations alongside the existing ones:

```
"Check file overlap\nfor next N tasks" [shape=diamond];
"Dispatch parallel batch\n(max 3 agents)" [shape=box];
"Review each result\nsequentially" [shape=box];
"Run integration\ntest suite" [shape=box];
```

- [ ] **Step 5: Verify**

```bash
grep "Parallel Dispatch" skills/subagent-driven-development/SKILL.md
grep "parallel-dispatch-guide.md" skills/subagent-driven-development/SKILL.md
grep "zero file overlap" skills/subagent-driven-development/SKILL.md
grep "Check file overlap" skills/subagent-driven-development/SKILL.md
wc -l skills/subagent-driven-development/SKILL.md
```

Expected: all matches found, file ~370 lines (327 + ~40 new).

- [ ] **Step 6: Commit**

```bash
git add skills/subagent-driven-development/SKILL.md
git commit -m "feat: add selective parallel dispatch to subagent-driven-development"
```

---

### Checkpoint: After Tasks 1-2 (Parallel Execution)

- [ ] `parallel-dispatch-guide.md` exists with algorithm, examples, failure handling
- [ ] `subagent-driven-development/SKILL.md` has "Parallel Dispatch" section
- [ ] Red Flags updated (old "never parallel" replaced with overlap-aware rule)
- [ ] Process flow diagram has parallel path
- [ ] No stale references

---

### Task 3: Add spec-driven test generation to TDD skill

**Files:**
- Modify: `skills/test-driven-development/SKILL.md`

- [ ] **Step 1: Read the current file**

Read `skills/test-driven-development/SKILL.md` to find the "When to Use" / "When NOT to use" section and the "The TDD Cycle" section. The new content goes between them.

- [ ] **Step 2: Add "Spec-Driven Test Generation" section**

After the "When NOT to use" paragraph (and the "Related:" note about browser testing) and BEFORE "## The TDD Cycle", add:

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

- [ ] **Step 3: Verify**

```bash
grep "Spec-Driven Test Generation" skills/test-driven-development/SKILL.md
grep "Bulk RED" skills/test-driven-development/SKILL.md
grep "edge case tests" skills/test-driven-development/SKILL.md
wc -l skills/test-driven-development/SKILL.md
```

Expected: all matches found, file ~430 lines (379 + ~50 new).

- [ ] **Step 4: Commit**

```bash
git add skills/test-driven-development/SKILL.md
git commit -m "feat: add spec-driven test generation to TDD skill"
```

---

### Checkpoint: After Task 3 (Test Generation)

- [ ] `test-driven-development/SKILL.md` has "Spec-Driven Test Generation" section
- [ ] Section placed BEFORE "The TDD Cycle" (sets up bulk RED before the normal cycle)
- [ ] Contains concrete TypeScript test example
- [ ] Contains edge case generation table
- [ ] Contains "Bulk RED → Incremental GREEN" flow diagram

---

### Task 4: Strengthen architecture axis in requesting-code-review

**Files:**
- Modify: `skills/requesting-code-review/SKILL.md`

- [ ] **Step 1: Read the current file**

Read `skills/requesting-code-review/SKILL.md` to find "### 3. Architecture" within the Five-Axis Review Framework.

- [ ] **Step 2: Replace the Architecture axis bullets**

Find the "### 3. Architecture" section. Replace the existing 4 bullets:

```markdown
- Does the change follow existing patterns or introduce a new one?
- Does it maintain clean module boundaries?
- Is there code duplication that should be shared?
- Are dependencies flowing in the right direction?
```

With this expanded list:

```markdown
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

- [ ] **Step 3: Verify**

```bash
grep -c "^-" skills/requesting-code-review/SKILL.md | head -1
grep "Hyrum" skills/requesting-code-review/SKILL.md
grep "coupling" skills/requesting-code-review/SKILL.md
```

Expected: "Hyrum" and "coupling" matches found.

- [ ] **Step 4: Commit**

```bash
git add skills/requesting-code-review/SKILL.md
git commit -m "feat: expand architecture review axis with coupling, Hyrum's Law, dependency cycles"
```

---

### Task 5: Add self-healing review loop to requesting-code-review

**Files:**
- Modify: `skills/requesting-code-review/SKILL.md`

- [ ] **Step 1: Read the current file**

Read `skills/requesting-code-review/SKILL.md` to find the "Domain Skill Sub-Checks" section and the "Integration with Workflows" section. The new content goes between them.

- [ ] **Step 2: Add "Self-Healing Review Loop" section**

After "Domain Skill Sub-Checks" and BEFORE "Integration with Workflows", add:

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

- [ ] **Step 3: Verify**

```bash
grep "Self-Healing Review Loop" skills/requesting-code-review/SKILL.md
grep "Max 3 rounds" skills/requesting-code-review/SKILL.md
grep "Dispatch fix agent" skills/requesting-code-review/SKILL.md
```

Expected: all matches found.

- [ ] **Step 4: Commit**

```bash
git add skills/requesting-code-review/SKILL.md
git commit -m "feat: add self-healing review loop to requesting-code-review"
```

---

### Task 6: Add review sizing gate to requesting-code-review

**Files:**
- Modify: `skills/requesting-code-review/SKILL.md`

- [ ] **Step 1: Read the current file**

Read `skills/requesting-code-review/SKILL.md` to find the "Change Sizing" section.

- [ ] **Step 2: Add "Review Sizing Gate" section**

After the "Change Sizing" section (which ends with the splitting guidance), add:

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

- [ ] **Step 3: Verify**

```bash
grep "Review Sizing Gate" skills/requesting-code-review/SKILL.md
grep "LINES_CHANGED" skills/requesting-code-review/SKILL.md
grep ">1000" skills/requesting-code-review/SKILL.md
```

Expected: all matches found.

- [ ] **Step 4: Commit**

```bash
git add skills/requesting-code-review/SKILL.md
git commit -m "feat: add review sizing gate to requesting-code-review"
```

---

### Checkpoint: After Tasks 4-6 (Architecture Review)

- [ ] Architecture axis has 9 bullets (was 4)
- [ ] Self-Healing Review Loop section exists with flow diagram, 3-round max, anti-rationalizations
- [ ] Review Sizing Gate section exists with line count thresholds
- [ ] All 3 additions flow naturally with existing content
- [ ] No stale references

---

### Task 7: Final integration verification

**Files:**
- Verify: all files modified in Tasks 1-6

- [ ] **Step 1: Verify no stale references**

```bash
for f in skills/subagent-driven-development/SKILL.md skills/subagent-driven-development/parallel-dispatch-guide.md skills/test-driven-development/SKILL.md skills/requesting-code-review/SKILL.md; do
  echo "=== $f ==="
  grep "superpowers:" "$f" || echo "Clean"
done
```

Expected: all "Clean".

- [ ] **Step 2: Verify all cross-references resolve**

```bash
grep "parallel-dispatch-guide.md" skills/subagent-driven-development/SKILL.md
```

Must show a match.

- [ ] **Step 3: Verify YAML frontmatter intact**

```bash
for skill in subagent-driven-development test-driven-development requesting-code-review; do
  echo "=== $skill ==="
  head -4 "skills/$skill/SKILL.md"
done
```

Expected: all have valid frontmatter.

- [ ] **Step 4: Verify file sizes are reasonable**

```bash
for f in skills/subagent-driven-development/SKILL.md skills/subagent-driven-development/parallel-dispatch-guide.md skills/test-driven-development/SKILL.md skills/requesting-code-review/SKILL.md; do
  echo "$(wc -l < "$f") $f"
done
```

Expected: no SKILL.md over 500 lines.

- [ ] **Step 5: Run acceptance tests from spec**

```bash
echo "=== Acceptance tests ==="
echo "1. Parallel dispatch section exists:"
grep "## Parallel Dispatch" skills/subagent-driven-development/SKILL.md && echo "PASS" || echo "FAIL"

echo "2. Safety gate (max 3, shared file rule):"
grep "Max 3 parallel agents" skills/subagent-driven-development/SKILL.md && grep "ANY shared file" skills/subagent-driven-development/SKILL.md && echo "PASS" || echo "FAIL"

echo "3. Red flags updated:"
grep "zero file overlap" skills/subagent-driven-development/SKILL.md && echo "PASS" || echo "FAIL"

echo "4. Spec-driven test generation:"
grep "## Spec-Driven Test Generation" skills/test-driven-development/SKILL.md && echo "PASS" || echo "FAIL"

echo "5. Architecture axis expanded:"
grep "Hyrum" skills/requesting-code-review/SKILL.md && grep "coupling" skills/requesting-code-review/SKILL.md && echo "PASS" || echo "FAIL"

echo "6. Self-healing loop:"
grep "## Self-Healing Review Loop" skills/requesting-code-review/SKILL.md && echo "PASS" || echo "FAIL"

echo "7. Sizing gate:"
grep "## Review Sizing Gate" skills/requesting-code-review/SKILL.md && echo "PASS" || echo "FAIL"
```

Expected: all 7 PASS.

---

## Summary

| Task | Enhancement | Files | Estimated lines added |
|------|------------|-------|----------------------|
| 1 | Parallel dispatch guide | Create: `parallel-dispatch-guide.md` | ~75 |
| 2 | Parallel dispatch in skill | Modify: `subagent-driven-development/SKILL.md` | ~40 |
| 3 | Spec-driven test generation | Modify: `test-driven-development/SKILL.md` | ~50 |
| 4 | Architecture axis expansion | Modify: `requesting-code-review/SKILL.md` | ~5 |
| 5 | Self-healing review loop | Modify: `requesting-code-review/SKILL.md` | ~40 |
| 6 | Review sizing gate | Modify: `requesting-code-review/SKILL.md` | ~15 |
| 7 | Integration verification | Verify all | 0 |

**Total: 7 tasks, 1 new file, 3 modified skills, ~225 lines added**

**Parallelization:** Tasks 1-2 (parallel dispatch), Task 3 (test generation), and Tasks 4-6 (code review) touch completely different files — all 3 groups can be dispatched in parallel.

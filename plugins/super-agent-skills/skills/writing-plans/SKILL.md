---
name: writing-plans
description: "Use when you have a spec or requirements for a multi-step task, before touching code"
phase: plan
produces:
  - implementation-plan
chainsTo:
  - subagent-driven-development
  - compound-engineering
  - executing-plans
chainsFrom:
  - superthink
  - brainstorming
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Save plans to:** `docs/super-agent-skills/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## Codebase Architecture Analysis

Before constructing the dependency graph, dispatch a single `code-architect` agent to analyze the existing codebase and produce an implementation blueprint. This offloads the expensive pattern-scanning and file-mapping work from your context.

**Dispatch the architect with:**
- The spec/design document content (or a summary of key requirements)
- The chosen approach from brainstorming (if one was selected)
- Instruction to focus on the areas of the codebase relevant to this feature

Use the Agent tool with `subagent_type: "super-agent-skills:code-architect"`.

**Use the architect's output as input, not as the final plan:**
- The architect's **file map** tells you which files to create/modify — saves you from deep codebase reads
- The architect's **pattern analysis** ensures your plan follows existing conventions
- The architect's **build sequence** is a starting point for your dependency graph
- You may disagree with the architect's suggestions based on spec requirements or your own judgment — the orchestrator retains final authority

**What the architect offloads from your context:**
- Deep codebase pattern scanning (grep/read operations across many files)
- File mapping (which files exist, what they do, what conventions they follow)
- Identifying similar features to use as implementation patterns

**What you still do inline:**
- Dependency graph construction (informed by architect output)
- Vertical slice design
- Task ordering and granularity decisions
- The actual plan document

## Dependency Graph

Before defining tasks, map what depends on what:

```
Database schema
    │
    ├── API models/types
    │       │
    │       ├── API endpoints
    │       │       │
    │       │       └── Frontend API client
    │       │               │
    │       │               └── UI components
    │       │
    │       └── Validation logic
    │
    └── Seed data / migrations
```

Implementation order follows the dependency graph bottom-up: build foundations first.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Vertical Slicing

Instead of building all the database, then all the API, then all the UI — build one complete feature path at a time:

**Bad (horizontal slicing):**
```
Task 1: Build entire database schema
Task 2: Build all API endpoints
Task 3: Build all UI components
Task 4: Connect everything
```

**Good (vertical slicing):**
```
Task 1: User can create an account (schema + API + UI for registration)
Task 2: User can log in (auth schema + API + UI for login)
Task 3: User can create a task (task schema + API + UI for creation)
```

Each vertical slice delivers working, testable functionality.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Inline vs Delegated Steps

This skill has two execution modes:

**Inline (runs on your model):** The thinking work — dependency graph construction, task ordering, vertical slice design, file structure decisions, scope check. These steps require judgment and conversation context. Do them yourself.

**Delegated (dispatched to subagent):** The writing work — turning the task list you've defined into a complete plan document following the required format. Once you have a finalized task list with dependencies and file maps, dispatch a plan-writer subagent using `skills/writing-plans/plan-writer-prompt.md`.

The boundary: when your task list is complete and ordered, switch to delegation.

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use super-agent-skills:subagent-driven-development (recommended) or super-agent-skills:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

**If the spec includes an "Acceptance Tests" section** (generated during brainstorming), incorporate those test skeletons into the plan's task steps. Each acceptance test should map to a specific task's test step — don't make the implementer re-derive tests that already exist in the spec.

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Remember
- Exact file paths always
- Complete code in every step — if a step changes code, show the code
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

## Self-Review

After the plan-writer subagent completes, look at the plan with fresh eyes and check it against the spec. This is a checklist you run yourself inline — not a subagent dispatch. The dispatch overhead is not worth it for a quick check.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Checkpoints

Add explicit checkpoints between phases:

```markdown
### Checkpoint: After Tasks 1-3
- [ ] All tests pass
- [ ] Application builds without errors
- [ ] Core user flow works end-to-end
- [ ] Review with human before proceeding
```

Checkpoints should occur after every 2-3 tasks. High-risk tasks should be early (fail fast).

## Anti-Rationalizations

| Thought | Reality |
|---------|---------|
| "This is too small to plan" | Small tasks with wrong order waste more time than planning costs. |
| "I'll figure it out as I go" | That's how you end up with a tangled mess and rework. 10 minutes of planning saves hours. |
| "The tasks are obvious" | Write them down anyway. Explicit tasks surface hidden dependencies and forgotten edge cases. |
| "Planning is overhead" | Planning IS the task. Implementation without a plan is just typing. |
| "I can hold it all in my head" | Context windows are finite. Written plans survive session boundaries and compaction. |

## Execution Handoff

After saving the plan, analyze the task list for independent streams, then offer the appropriate execution choice.

### Stream Detection

Before presenting options, check whether the plan's tasks group into 2+ independent streams:

1. **Group tasks by file overlap** — tasks touching the same files belong to the same stream
2. **Verify independence** — can each group be built and tested without the other groups?
3. **Check size** — each stream should have 3+ tasks (otherwise not worth splitting)

If 2+ independent streams detected (different files, independently testable, 3+ tasks each), recommend Compound. Otherwise, recommend Subagent-Driven.

### Present Options

**"Plan complete and saved to `docs/super-agent-skills/plans/<filename>.md`."**

**If independent streams detected:**

> "This plan has [N] independent work streams ([stream names]). Three execution options:
>
> **1. Compound (recommended)** — parallel execution across isolated worktrees, one stream per worktree, then integrate
>
> **2. Subagent-Driven** — sequential, fresh subagent per task, review between tasks
>
> **3. Inline Execution** — execute in this session with checkpoints
>
> Which approach?"

**If single stream:**

> "Two execution options:
>
> **1. Subagent-Driven (recommended)** — fresh subagent per task, review between tasks, fast iteration
>
> **2. Inline Execution** — execute in this session with checkpoints
>
> Which approach?"

### On Choice

**If Compound chosen:**
- **REQUIRED SUB-SKILL:** Use super-agent-skills:compound-engineering
- Pass the stream grouping (which tasks belong to which stream) and integration points (shared types, API contracts)

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use super-agent-skills:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use super-agent-skills:executing-plans
- Batch execution with checkpoints for review

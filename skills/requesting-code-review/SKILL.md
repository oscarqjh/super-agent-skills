---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch super-agent-skills:code-reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history. This keeps the reviewer focused on the work product, not your thought process, and preserves your own context for continued work.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code-reviewer subagent:**

Use Task tool with super-agent-skills:code-reviewer type, fill template at `code-reviewer.md`

**Placeholders:**
- `{WHAT_WAS_IMPLEMENTED}` - What you just built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit
- `{DESCRIPTION}` - Brief summary

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch super-agent-skills:code-reviewer subagent]
  WHAT_WAS_IMPLEMENTED: Verification and repair functions for conversation index
  PLAN_OR_REQUIREMENTS: Task 2 from docs/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## The Five-Axis Review Framework

Instruct the code-reviewer to evaluate across these dimensions:

### 1. Correctness
- Does the code match spec/task requirements?
- Are edge cases handled (null, empty, boundary values)?
- Are error paths handled (not just the happy path)?
- Do tests actually test the right things?

### 2. Readability & Simplicity
- Are names descriptive and consistent with project conventions?
- Is the control flow straightforward?
- Could this be done in fewer lines?
- Are abstractions earning their complexity?
- Are there dead code artifacts?

### 3. Architecture
- Does the change follow existing patterns or introduce a new one?
- Does it maintain clean module boundaries?
- Is there code duplication that should be shared?
- Are dependencies flowing in the right direction?

### 4. Security
- Is user input validated and sanitized?
- Are secrets kept out of code, logs, and version control?
- Are SQL queries parameterized?
- Are outputs encoded to prevent XSS?
- Is data from external sources treated as untrusted?
- See `references/security-checklist.md` for full checklist.

### 5. Performance
- Any N+1 query patterns?
- Any unbounded loops or unconstrained data fetching?
- Any synchronous operations that should be async?
- Any missing pagination on list endpoints?
- See `references/performance-checklist.md` for full checklist.

## Change Sizing

Small, focused changes are easier to review:

```
~100 lines changed  → Good. Reviewable in one sitting.
~300 lines changed  → Acceptable if it's a single logical change.
~1000 lines changed → Too large. Split it.
```

If a change is too large, ask the author to split using: vertical slices, by file group, or horizontal layers.

## Domain Skill Sub-Checks

For security-sensitive changes (auth, user input, external data), the reviewer should additionally invoke `super-agent-skills:security-and-hardening` for a focused security review.

For performance-sensitive changes (database queries, rendering, data processing), the reviewer should additionally invoke `super-agent-skills:performance-optimization` for a focused performance review.

## Integration with Workflows

**Subagent-Driven Development:**
- Review after EACH task
- Catch issues before they compound
- Fix before moving to next task

**Executing Plans:**
- Review after each batch (3 tasks)
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Anti-Rationalizations

| Thought | Reality |
|---------|---------|
| "It works, that's good enough" | Working code that's unreadable, insecure, or architecturally wrong creates debt that compounds. |
| "The tests pass, so it's good" | Tests are necessary but not sufficient. They don't catch architecture problems, security issues, or readability concerns. |
| "AI-generated code is probably fine" | AI code needs MORE scrutiny, not less. It's confident and plausible, even when wrong. |
| "We'll clean it up later" | Later never comes. The review is the quality gate — use it. |

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: requesting-code-review/code-reviewer.md

## Handoff

When review is complete and all issues are resolved, invoke `super-agent-skills:finishing-a-development-branch` to complete the work.

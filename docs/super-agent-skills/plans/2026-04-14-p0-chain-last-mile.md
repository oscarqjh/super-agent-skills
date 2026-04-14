# P0.1: Reliable Chain Last Mile Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use super-agent-skills:subagent-driven-development (recommended) or super-agent-skills:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the review → ship handoff as reliable as the other 3 handoffs in the orchestration chain.

**Architecture:** 4 targeted changes: HARD-GATE on requesting-code-review handoff, chain completion note in subagent-driven-development, PreToolUse hook on git push, worktree-optional note in finishing-a-development-branch.

**Tech Stack:** Markdown + JSON.

---

### Task 1: Add HARD-GATE to requesting-code-review handoff

**Files:**
- Modify: `skills/requesting-code-review/SKILL.md`

- [ ] **Step 1: Read the file and find the handoff section**

Read `skills/requesting-code-review/SKILL.md`. Find the "## Handoff" section at the end of the file (last ~3 lines).

- [ ] **Step 2: Replace the handoff section**

Find:

```markdown
## Handoff

When review is complete and all issues are resolved, invoke `super-agent-skills:finishing-a-development-branch` to complete the work.
```

Replace with:

```markdown
## Handoff

<HARD-GATE>
When review is complete and all issues are resolved, you MUST invoke `super-agent-skills:finishing-a-development-branch`. Do NOT commit, push, or claim the work is done without invoking this skill first. Even if the user says "commit" or "push" — invoke finishing-a-development-branch, which will handle the commit/push after running the pre-merge checklist.
</HARD-GATE>
```

- [ ] **Step 3: Verify**

```bash
grep "HARD-GATE" skills/requesting-code-review/SKILL.md
grep "MUST invoke" skills/requesting-code-review/SKILL.md
grep "Do NOT commit" skills/requesting-code-review/SKILL.md
```

Expected: all 3 matches found.

- [ ] **Step 4: Commit**

```bash
git add skills/requesting-code-review/SKILL.md
git commit -m "feat: add HARD-GATE to requesting-code-review handoff to finishing-a-development-branch"
```

---

### Task 2: Add chain completion note to subagent-driven-development

**Files:**
- Modify: `skills/subagent-driven-development/SKILL.md`

- [ ] **Step 1: Read the file and find the process flow section**

Read `skills/subagent-driven-development/SKILL.md`. Find the closing of the process flow graphviz diagram (the line ` ``` ` that closes the dot code block, around line 95-96).

- [ ] **Step 2: Add chain completion note**

Immediately AFTER the closing ` ``` ` of the graphviz diagram, add:

```markdown

**Chain completion:** After requesting-code-review approves the implementation, it will invoke `super-agent-skills:finishing-a-development-branch` to handle the final commit/push/merge. Do NOT commit or push directly — the chain handles it.
```

- [ ] **Step 3: Verify**

```bash
grep "Chain completion" skills/subagent-driven-development/SKILL.md
grep "Do NOT commit or push directly" skills/subagent-driven-development/SKILL.md
```

Expected: both matches found.

- [ ] **Step 4: Commit**

```bash
git add skills/subagent-driven-development/SKILL.md
git commit -m "feat: add chain completion note to subagent-driven-development"
```

---

### Task 3: Add PreToolUse hook for git push reminder

**Files:**
- Modify: `hooks/hooks.json`

- [ ] **Step 1: Read the current hooks.json**

Read `hooks/hooks.json`. It currently has only a SessionStart hook.

- [ ] **Step 2: Replace hooks.json with updated version**

Write the complete `hooks/hooks.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "If this command includes 'git push', have you invoked super-agent-skills:finishing-a-development-branch first? The finishing skill runs the pre-merge checklist (no TODOs, no console.logs, tests pass, lint clean) before pushing. If you haven't invoked it yet, do so now instead of pushing directly."
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 3: Verify valid JSON**

```bash
python3 -c "import json; json.load(open('hooks/hooks.json')); print('Valid JSON')"
grep "PreToolUse" hooks/hooks.json
grep "finishing-a-development-branch" hooks/hooks.json
```

Expected: "Valid JSON", both grep matches.

- [ ] **Step 4: Commit**

```bash
git add hooks/hooks.json
git commit -m "feat: add PreToolUse hook to remind agent about finishing-a-development-branch before git push"
```

---

### Task 4: Add worktree-optional note to finishing-a-development-branch

**Files:**
- Modify: `skills/finishing-a-development-branch/SKILL.md`

- [ ] **Step 1: Read the file and find Step 5**

Read `skills/finishing-a-development-branch/SKILL.md`. Find "### Step 5: Cleanup Worktree" section.

- [ ] **Step 2: Add worktree-optional note**

After the Step 5 section (after "**For Option 3:** Keep worktree." or the equivalent closing line of Step 5), add:

```markdown
**If not using a worktree** (working directly on a branch), skip Step 5. The pre-merge checklist (Step 1.5) and completion options (Steps 2-4) still apply regardless of whether a worktree is involved.
```

- [ ] **Step 3: Verify**

```bash
grep "not using a worktree" skills/finishing-a-development-branch/SKILL.md
```

Expected: match found.

- [ ] **Step 4: Commit**

```bash
git add skills/finishing-a-development-branch/SKILL.md
git commit -m "feat: add worktree-optional note to finishing-a-development-branch"
```

---

### Checkpoint: Final Verification

- [ ] requesting-code-review has HARD-GATE with "MUST invoke" and "Do NOT commit, push"
- [ ] subagent-driven-development has "Chain completion" note after process flow
- [ ] hooks.json has PreToolUse entry with Bash matcher and finishing-a-development-branch prompt
- [ ] hooks.json is valid JSON
- [ ] finishing-a-development-branch has worktree-optional note
- [ ] No stale `superpowers:` references in any modified file

```bash
for f in skills/requesting-code-review/SKILL.md skills/subagent-driven-development/SKILL.md hooks/hooks.json skills/finishing-a-development-branch/SKILL.md; do
  echo "=== $f ==="
  grep "superpowers:" "$f" || echo "Clean"
done
```

---

## Summary

| Task | Change | File |
|------|--------|------|
| 1 | HARD-GATE on review → ship handoff | `requesting-code-review/SKILL.md` |
| 2 | Chain completion note | `subagent-driven-development/SKILL.md` |
| 3 | PreToolUse hook for git push | `hooks/hooks.json` |
| 4 | Worktree-optional note | `finishing-a-development-branch/SKILL.md` |

**Total: 4 tasks, 4 files, ~25 lines changed**

**All tasks are independent** — can be dispatched in parallel.

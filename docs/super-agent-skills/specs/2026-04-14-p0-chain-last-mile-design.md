# P0.1: Reliable Review → Ship Handoff

## Objective

Make the orchestration chain's final handoff (requesting-code-review → finishing-a-development-branch) as reliable as the other 3 handoffs in the chain. Currently the agent bypasses finishing-a-development-branch when the user says "commit" or "push" directly.

**Success criteria:**
- requesting-code-review has a HARD-GATE that forces invocation of finishing-a-development-branch
- subagent-driven-development explicitly states the chain continues through finishing-a-development-branch
- A PreToolUse hook reminds the agent to invoke finishing-a-development-branch before any git push
- finishing-a-development-branch works correctly even without git worktrees

## Tech Stack

Markdown authoring + JSON hook configuration.

## Files to Modify

| File | Change type | Estimated change |
|------|------------|-----------------|
| `skills/requesting-code-review/SKILL.md` | Replace soft handoff with HARD-GATE | ~5 lines replaced |
| `skills/subagent-driven-development/SKILL.md` | Add chain completion note after process flow | ~3 lines added |
| `skills/finishing-a-development-branch/SKILL.md` | Add worktree-optional note | ~3 lines added |
| `hooks/hooks.json` | Add PreToolUse hook for git push reminder | ~15 lines added |

---

## Change 1: HARD-GATE on requesting-code-review handoff

Replace the current soft handoff at the end of `skills/requesting-code-review/SKILL.md`:

```markdown
## Handoff

When review is complete and all issues are resolved, invoke `super-agent-skills:finishing-a-development-branch` to complete the work.
```

With:

```markdown
## Handoff

<HARD-GATE>
When review is complete and all issues are resolved, you MUST invoke `super-agent-skills:finishing-a-development-branch`. Do NOT commit, push, or claim the work is done without invoking this skill first. Even if the user says "commit" or "push" — invoke finishing-a-development-branch, which will handle the commit/push after running the pre-merge checklist.
</HARD-GATE>
```

## Change 2: Chain completion note in subagent-driven-development

After the process flow graphviz diagram (after the closing ` ``` `) in `skills/subagent-driven-development/SKILL.md`, add:

```markdown
**Chain completion:** After requesting-code-review approves the implementation, it will invoke `super-agent-skills:finishing-a-development-branch` to handle the final commit/push/merge. Do NOT commit or push directly — the chain handles it.
```

## Change 3: PreToolUse hook for git push

Update `hooks/hooks.json` to add a PreToolUse prompt-based hook that fires on Bash tool use:

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

This is a prompt-based hook — it doesn't block execution, it injects a reminder into the agent's context right before a Bash command runs. Lightweight and non-breaking.

## Change 4: Worktree-optional note in finishing-a-development-branch

In `skills/finishing-a-development-branch/SKILL.md`, after the "Step 5: Cleanup Worktree" section, add:

```markdown
**If not using a worktree** (working directly on a branch), skip Step 5. The pre-merge checklist (Step 1.5) and completion options (Steps 2-4) still apply regardless of whether a worktree is involved.
```

---

## Boundaries

- **Always:** Keep HARD-GATE language consistent with brainstorming skill's pattern
- **Never:** Block git commit (per-task commits during subagent-driven-dev are fine — only the final push needs the gate)
- **Never:** Make the hook blocking — it's a reminder, not an enforcer

## Testing Strategy

- [ ] requesting-code-review ends with HARD-GATE block
- [ ] subagent-driven-development has chain completion note
- [ ] hooks.json has PreToolUse entry with correct matcher and prompt
- [ ] finishing-a-development-branch has worktree-optional note
- [ ] hooks.json is valid JSON

## Acceptance Tests

- [ ] `test: requesting-code-review has HARD-GATE`
      Given: the modified SKILL.md
      When: searching for "HARD-GATE"
      Then: block exists with "MUST invoke" and "Do NOT commit, push"

- [ ] `test: hook fires on Bash tool use`
      Given: hooks.json with PreToolUse matcher "Bash"
      When: agent runs any Bash command
      Then: prompt about finishing-a-development-branch is injected

- [ ] `test: finishing skill works without worktree`
      Given: the modified SKILL.md
      When: searching for "not using a worktree"
      Then: note exists explaining to skip Step 5

# P0.2: Backlog & Changelog Workflow Artifacts Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use super-agent-skills:subagent-driven-development (recommended) or super-agent-skills:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Consolidate workflow artifacts under `docs/super-agent-skills/`, restructure the backlog, create a changelog, and integrate both into the orchestration chain.

**Architecture:** Move existing files via git mv, create new artifacts, update path references in 4 skill files + CLAUDE.md. Backlog/changelog integration adds ~10 lines each to brainstorming and finishing-a-development-branch.

**Tech Stack:** Markdown + git mv.

---

### Task 1: Move existing artifacts to docs/super-agent-skills/

**Files:**
- Move: `docs/specs/` → `docs/super-agent-skills/specs/`
- Move: `docs/plans/` → `docs/super-agent-skills/plans/`
- Move: `docs/backlogs.md` → `docs/super-agent-skills/backlogs.md`
- Move: `docs/claude-engineer-plugin-design.md` → `docs/super-agent-skills/specs/` (legacy design spec)

- [ ] **Step 1: Create directory and move files**

```bash
mkdir -p docs/super-agent-skills
git mv docs/specs docs/super-agent-skills/specs
git mv docs/plans docs/super-agent-skills/plans
git mv docs/backlogs.md docs/super-agent-skills/backlogs.md
git mv docs/claude-engineer-plugin-design.md docs/super-agent-skills/specs/claude-engineer-plugin-design.md
```

- [ ] **Step 2: Verify structure**

```bash
ls docs/super-agent-skills/
ls docs/super-agent-skills/specs/
ls docs/super-agent-skills/plans/
```

Expected: backlogs.md + changelog.md (not yet) at root. specs/ has all spec files + legacy design. plans/ has all plan files.

- [ ] **Step 3: Verify docs/ only has setup guides**

```bash
ls docs/*.md
```

Expected: only setup guides remain (claude-code-setup.md, cursor-setup.md, copilot-setup.md, gemini-cli-setup.md, getting-started.md, opencode-setup.md, windsurf-setup.md).

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor: move workflow artifacts to docs/super-agent-skills/"
```

---

### Task 2: Restructure backlogs.md to flat format

**Files:**
- Rewrite: `docs/super-agent-skills/backlogs.md`

- [ ] **Step 1: Rewrite backlogs.md**

Replace the entire content of `docs/super-agent-skills/backlogs.md` with:

```markdown
# Backlog

## In Progress
- [ ] P0.2: Backlog & changelog as first-class workflow artifacts — spec: docs/super-agent-skills/specs/2026-04-14-p0-backlog-changelog-design.md

## Up Next
- [ ] P0.3: Deterministic chain enforcement (PostToolUse hooks, chain state tracking)
- [ ] Phase 2: New agents (architecture-reviewer, test-generator, dependency-auditor, migration-assistant)

## Ideas (Unprioritized)
- [ ] Phase 3: New skills (compound engineering, shift-right testing, threat modeling, observability, project customization)
- [ ] Phase 4: MCP integrations (Context7, Sentry, browser automation, database)
- [ ] Phase 5: Structural improvements (code health gates, token tracking, feedback loops)
- [ ] Phase 6: Documentation (authoring guide, contributing guide, example workflows)
- [ ] Improve natural language trigger robustness for skill routing
- [ ] Investigate content-based PreToolUse matcher (narrow git push hook to only fire on push commands)

---

## Completed

### P0.1: Chain last mile reliability (2026-04-14)
- [x] HARD-GATE on requesting-code-review handoff
- [x] Chain completion note in subagent-driven-development
- [x] PreToolUse hook on git push
- [x] Worktree-optional note in finishing-a-development-branch

### Phase 1: Skill Enhancements (2026-04-14)
- [x] 1.1 Parallel execution in subagent-driven-development
- [x] 1.2 Spec-driven test generation in TDD
- [x] 1.3 Supply chain security in security-and-hardening
- [x] 1.4 Mid-session context management in context-engineering
- [x] 1.5 Architecture review + self-healing loop + sizing gate in requesting-code-review
- [x] 1.6 Spec-to-test bridge in brainstorming

### Initial Plugin (2026-04-13)
- [x] 24 skills merged from superpowers + agent-skills
- [x] 3 agent personas, 4 reference checklists
- [x] 9 slash commands including /superthink
- [x] Multi-environment setup docs
- [x] Session-start hook
```

- [ ] **Step 2: Verify**

```bash
grep "## In Progress" docs/super-agent-skills/backlogs.md
grep "## Up Next" docs/super-agent-skills/backlogs.md
grep "## Ideas" docs/super-agent-skills/backlogs.md
grep "## Completed" docs/super-agent-skills/backlogs.md
```

Expected: all 4 sections found.

- [ ] **Step 3: Commit**

```bash
git add docs/super-agent-skills/backlogs.md
git commit -m "refactor: restructure backlog to flat format with In Progress / Up Next / Ideas / Completed"
```

---

### Task 3: Create changelog.md

**Files:**
- Create: `docs/super-agent-skills/changelog.md`

- [ ] **Step 1: Create changelog**

Write `docs/super-agent-skills/changelog.md`:

```markdown
# Changelog

All notable changes to the super-agent-skills plugin.

Format follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

## [1.1.0] — 2026-04-14

### Added
- Supply chain security: dependency auditing, license compliance, AI-specific vulnerabilities (security-and-hardening + new reference)
- Mid-session context management: degradation signals, tiered memory model, recovery pattern (context-engineering)
- Spec-to-test bridge: acceptance test skeleton generation from success criteria (brainstorming + writing-plans)
- Selective parallel dispatch: file overlap safety gate, max 3 agents (subagent-driven-development + new guide)
- Spec-driven test generation: bulk RED phase from acceptance criteria (test-driven-development)
- Architecture review expansion: 9-bullet axis with Hyrum's Law, coupling analysis (requesting-code-review)
- Self-healing review loop: automated fix-and-re-review up to 3 rounds (requesting-code-review)
- Review sizing gate: hard block on reviews >1000 lines (requesting-code-review)
- Chain last mile: HARD-GATE on review→ship handoff, PreToolUse hook on git push, worktree-optional finishing
- Backlog & changelog as first-class workflow artifacts under docs/super-agent-skills/

## [1.0.0] — 2026-04-13

### Added
- Initial release: 24 skills (6 chain, 10 domain, 7 support, 1 meta)
- 3 agent personas (code-reviewer, test-engineer, security-auditor)
- 4 reference checklists (security, performance, testing, accessibility)
- 9 slash commands including /superthink universal entry point
- Session-start hook for automatic skill routing
- Multi-environment setup docs (Claude Code, Cursor, OpenCode, Gemini, Windsurf, Copilot)
- Plugin marketplace registration
```

- [ ] **Step 2: Verify**

```bash
grep "Unreleased" docs/super-agent-skills/changelog.md
grep "1.1.0" docs/super-agent-skills/changelog.md
grep "1.0.0" docs/super-agent-skills/changelog.md
```

- [ ] **Step 3: Commit**

```bash
git add docs/super-agent-skills/changelog.md
git commit -m "feat: create changelog with historical entries"
```

---

### Checkpoint: After Tasks 1-3

- [ ] `docs/super-agent-skills/` contains: backlogs.md, changelog.md, specs/, plans/
- [ ] `docs/` contains only setup guides (no specs, plans, or backlogs)
- [ ] backlogs.md has 4 sections
- [ ] changelog.md has 1.0.0 and 1.1.0 entries

---

### Task 4: Update skill path references (brainstorming + writing-plans + CLAUDE.md)

**Files:**
- Modify: `skills/brainstorming/SKILL.md`
- Modify: `skills/writing-plans/SKILL.md`
- Modify: `CLAUDE.md`

- [ ] **Step 1: Update brainstorming skill paths**

Read `skills/brainstorming/SKILL.md`. Find all occurrences of `docs/specs/` and replace with `docs/super-agent-skills/specs/`.

There should be 2 occurrences:
1. In the checklist: "save to `docs/specs/YYYY-MM-DD-<topic>-design.md`"
2. In the "After the Design" section: "Write the validated design (spec) to `docs/specs/YYYY-MM-DD-<topic>-design.md`"

- [ ] **Step 2: Update writing-plans skill paths**

Read `skills/writing-plans/SKILL.md`. Find all occurrences of `docs/plans/` and replace with `docs/super-agent-skills/plans/`.

There should be ~3 occurrences:
1. "Save plans to" line
2. In the execution handoff section
3. Possibly in the plan document header

- [ ] **Step 3: Update CLAUDE.md**

Read `CLAUDE.md`. Replace:
- `docs/specs/` → `docs/super-agent-skills/specs/`
- `docs/plans/` → `docs/super-agent-skills/plans/`

- [ ] **Step 4: Verify no old paths remain**

```bash
grep -r "docs/specs/" skills/ CLAUDE.md || echo "Clean — no old spec paths"
grep -r "docs/plans/" skills/ CLAUDE.md || echo "Clean — no old plan paths"
grep "docs/super-agent-skills/specs/" skills/brainstorming/SKILL.md
grep "docs/super-agent-skills/plans/" skills/writing-plans/SKILL.md
```

Expected: old paths clean, new paths found.

- [ ] **Step 5: Commit**

```bash
git add skills/brainstorming/SKILL.md skills/writing-plans/SKILL.md CLAUDE.md
git commit -m "refactor: update spec/plan paths to docs/super-agent-skills/"
```

---

### Task 5: Add backlog integration to brainstorming skill

**Files:**
- Modify: `skills/brainstorming/SKILL.md`

- [ ] **Step 1: Read the file and find the insertion point**

Read `skills/brainstorming/SKILL.md`. Find the "Acceptance Test Generation" section (added in Phase 1A). The new content goes AFTER that section and BEFORE "User Review Gate".

- [ ] **Step 2: Add backlog update section**

After "Acceptance Test Generation" and before "**User Review Gate:**", add:

```markdown
**Backlog Update:**
After writing the spec, add the work item to `docs/super-agent-skills/backlogs.md` under "In Progress":
> "Added '[item name]' to the backlog under In Progress. Spec at `docs/super-agent-skills/specs/[path]`."

If the user mentions a parallel idea during brainstorming (something unrelated to the current task), capture it in the backlog under "Ideas (Unprioritized)" so it doesn't get lost:
> "Captured '[idea]' in the backlog Ideas section for later."
```

- [ ] **Step 3: Verify**

```bash
grep "Backlog Update" skills/brainstorming/SKILL.md
grep "In Progress" skills/brainstorming/SKILL.md
grep "Ideas (Unprioritized)" skills/brainstorming/SKILL.md
```

Expected: all matches found.

- [ ] **Step 4: Commit**

```bash
git add skills/brainstorming/SKILL.md
git commit -m "feat: add backlog integration to brainstorming skill"
```

---

### Task 6: Add backlog/changelog update to finishing-a-development-branch skill

**Files:**
- Modify: `skills/finishing-a-development-branch/SKILL.md`

- [ ] **Step 1: Read the file and find the insertion point**

Read `skills/finishing-a-development-branch/SKILL.md`. Find the worktree-optional note (added in P0.1) — the new content goes after it, before "Quick Reference" or "Common Mistakes".

- [ ] **Step 2: Add Step 6**

After the worktree-optional note, add:

```markdown
### Step 6: Update Backlog & Changelog

After completing the chosen option (merge, PR, keep, or discard):

1. **Update backlog:** Read `docs/super-agent-skills/backlogs.md`. Mark any related "In Progress" items as complete (`[x]`). Move completed items to the "Completed" section with today's date.
2. **Update changelog:** Append a one-line entry to `docs/super-agent-skills/changelog.md` under `[Unreleased]` describing what was shipped.
3. **Suggest next:** If the backlog "In Progress" is now empty, suggest the next item from "Up Next":
   > "Backlog and changelog updated. Next in backlog: [next item]. Want to start on it?"
```

- [ ] **Step 3: Verify**

```bash
grep "Step 6: Update Backlog" skills/finishing-a-development-branch/SKILL.md
grep "changelog.md" skills/finishing-a-development-branch/SKILL.md
grep "Suggest next" skills/finishing-a-development-branch/SKILL.md
```

Expected: all matches found.

- [ ] **Step 4: Commit**

```bash
git add skills/finishing-a-development-branch/SKILL.md
git commit -m "feat: add backlog/changelog update step to finishing-a-development-branch"
```

---

### Task 7: Integration verification

- [ ] **Step 1: Verify artifact structure**

```bash
echo "=== Artifact structure ===" 
ls docs/super-agent-skills/
ls docs/super-agent-skills/specs/ | head -5
ls docs/super-agent-skills/plans/ | head -5
```

Expected: backlogs.md, changelog.md, specs/, plans/ all present.

- [ ] **Step 2: Verify no old paths in skills**

```bash
echo "=== Old paths ===" 
grep -rn "docs/specs/" skills/ CLAUDE.md 2>/dev/null || echo "Clean"
grep -rn "docs/plans/" skills/ CLAUDE.md 2>/dev/null || echo "Clean"
```

Expected: both "Clean".

- [ ] **Step 3: Verify new paths exist in skills**

```bash
grep "docs/super-agent-skills/specs/" skills/brainstorming/SKILL.md
grep "docs/super-agent-skills/plans/" skills/writing-plans/SKILL.md
grep "docs/super-agent-skills/backlogs.md" skills/brainstorming/SKILL.md
grep "docs/super-agent-skills/backlogs.md" skills/finishing-a-development-branch/SKILL.md
grep "docs/super-agent-skills/changelog.md" skills/finishing-a-development-branch/SKILL.md
```

Expected: all 5 matches.

- [ ] **Step 4: Verify docs/ only has setup guides**

```bash
ls docs/*.md
```

Expected: only setup guides (claude-code-setup.md, copilot-setup.md, cursor-setup.md, gemini-cli-setup.md, getting-started.md, opencode-setup.md, windsurf-setup.md).

---

## Summary

| Task | Change | Files |
|------|--------|-------|
| 1 | Move artifacts to docs/super-agent-skills/ | git mv (4 moves) |
| 2 | Restructure backlogs.md | Rewrite: backlogs.md |
| 3 | Create changelog.md | Create: changelog.md |
| 4 | Update path references | Modify: brainstorming, writing-plans, CLAUDE.md |
| 5 | Backlog integration in brainstorming | Modify: brainstorming/SKILL.md |
| 6 | Backlog/changelog update in finishing | Modify: finishing-a-development-branch/SKILL.md |
| 7 | Integration verification | Verify all |

**Dependencies:** Task 1 first (creates directory structure). Tasks 2-6 after Task 1 (all independent). Task 7 last.

**Parallelization:** Tasks 2+3 (backlogs + changelog) can parallel with Tasks 4+5+6 (skill updates) after Task 1.

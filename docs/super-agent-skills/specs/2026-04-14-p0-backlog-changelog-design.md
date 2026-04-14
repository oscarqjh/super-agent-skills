# P0.2: Backlog & Changelog as First-Class Workflow Artifacts

## Objective

Make backlog.md and changelog.md first-class artifacts in the orchestration chain. Consolidate all workflow artifacts (specs, plans, backlog, changelog) under `docs/super-agent-skills/`. Update skill default paths.

**Success criteria:**
- All workflow artifacts live under `docs/super-agent-skills/` (specs, plans, backlog, changelog)
- User-facing docs (setup guides) stay in `docs/`
- brainstorming skill offers to add items to backlog after writing spec
- brainstorming skill captures parallel ideas to backlog Ideas section
- finishing-a-development-branch skill updates backlog (mark complete) and changelog (append entry) after shipping
- backlog uses flat 3-section format (In Progress, Up Next, Ideas)
- changelog follows Keep a Changelog format

## Tech Stack

Markdown authoring + git mv for file moves.

## Files to Change

| File | Change |
|------|--------|
| `docs/super-agent-skills/` | NEW directory |
| `docs/super-agent-skills/backlogs.md` | Move from `docs/backlogs.md` + restructure to flat format |
| `docs/super-agent-skills/changelog.md` | NEW — historical entries from this session |
| `docs/super-agent-skills/specs/` | Move from `docs/specs/` (all files) |
| `docs/super-agent-skills/plans/` | Move from `docs/plans/` (all files) |
| `skills/brainstorming/SKILL.md` | Update default spec path + add backlog integration step |
| `skills/writing-plans/SKILL.md` | Update default plan path |
| `skills/finishing-a-development-branch/SKILL.md` | Add backlog/changelog update step |
| `CLAUDE.md` | Update spec/plan path references |

---

## Change 1: Move existing artifacts to new location

```bash
mkdir -p docs/super-agent-skills
git mv docs/specs docs/super-agent-skills/specs
git mv docs/plans docs/super-agent-skills/plans
git mv docs/backlogs.md docs/super-agent-skills/backlogs.md
```

The design spec file (claude-engineer-plugin-design.md) in docs/ is legacy — leave it or move it. Setup guides (claude-code-setup.md, cursor-setup.md, etc.) stay in docs/.

## Change 2: Restructure backlogs.md to flat format

Rewrite `docs/super-agent-skills/backlogs.md` with 3 sections:

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

## Change 3: Create changelog.md

Create `docs/super-agent-skills/changelog.md`:

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

## Change 4: Update brainstorming skill — backlog integration + new spec path

In `skills/brainstorming/SKILL.md`:

**(A) Update default spec path.** Find all occurrences of `docs/specs/` and replace with `docs/super-agent-skills/specs/`.

**(B) Add backlog integration.** After the "Spec Self-Review" section and the new "Acceptance Test Generation" section, BEFORE "User Review Gate", add:

```markdown
**Backlog Update:**
After writing the spec, add the work item to `docs/super-agent-skills/backlogs.md` under "In Progress":
> "Added '[item name]' to the backlog under In Progress. Spec at `docs/super-agent-skills/specs/[path]`."

If the user mentions a parallel idea during brainstorming (something unrelated to the current task), capture it in the backlog under "Ideas (Unprioritized)" so it doesn't get lost:
> "Captured '[idea]' in the backlog Ideas section for later."
```

## Change 5: Update writing-plans skill — new plan path

In `skills/writing-plans/SKILL.md`, find all occurrences of `docs/plans/` and replace with `docs/super-agent-skills/plans/`.

## Change 6: Update finishing-a-development-branch — backlog/changelog integration

In `skills/finishing-a-development-branch/SKILL.md`, after the existing Step 5 (Cleanup Worktree) and the worktree-optional note, add a new step:

```markdown
### Step 6: Update Backlog & Changelog

After completing the chosen option (merge, PR, keep, or discard):

1. **Update backlog:** Read `docs/super-agent-skills/backlogs.md`. Mark any related "In Progress" items as complete (`[x]`). Move completed items to the "Completed" section with today's date.
2. **Update changelog:** Append a one-line entry to `docs/super-agent-skills/changelog.md` under `[Unreleased]` describing what was shipped.
3. **Suggest next:** If the backlog "In Progress" is now empty, suggest the next item from "Up Next":
   > "Backlog and changelog updated. Next in backlog: [next item]. Want to start on it?"
```

## Change 7: Update CLAUDE.md — path references

In `CLAUDE.md`, update:
- `docs/specs/` → `docs/super-agent-skills/specs/`
- `docs/plans/` → `docs/super-agent-skills/plans/`

---

## Boundaries

- **Always:** Keep backlog flat — one line per item, details in specs/plans
- **Never:** Let the backlog become a project management system — it's a lightweight capture tool
- **Never:** Block the chain if backlog/changelog update fails — it's a nice-to-have step, not a gate

## Testing Strategy

- [ ] All existing spec/plan files accessible at new paths
- [ ] No broken references to old `docs/specs/` or `docs/plans/` paths in skill files
- [ ] backlogs.md has 3 sections (In Progress, Up Next, Ideas) + Completed
- [ ] changelog.md has entries for 1.0.0 and 1.1.0
- [ ] brainstorming skill references new spec path
- [ ] writing-plans skill references new plan path
- [ ] finishing-a-development-branch has Step 6 (backlog/changelog update)
- [ ] CLAUDE.md references new paths

## Acceptance Tests

- [ ] `test: artifacts under docs/super-agent-skills/`
      Given: the repo after changes
      When: listing docs/super-agent-skills/
      Then: contains backlogs.md, changelog.md, specs/, plans/

- [ ] `test: brainstorming references new spec path`
      Given: skills/brainstorming/SKILL.md
      When: searching for spec path
      Then: uses docs/super-agent-skills/specs/ (not docs/specs/)

- [ ] `test: brainstorming has backlog integration`
      Given: skills/brainstorming/SKILL.md
      When: searching for "Backlog Update"
      Then: section exists with In Progress and Ideas capture

- [ ] `test: finishing has Step 6`
      Given: skills/finishing-a-development-branch/SKILL.md
      When: searching for "Update Backlog & Changelog"
      Then: step exists with 3 sub-steps (update backlog, update changelog, suggest next)

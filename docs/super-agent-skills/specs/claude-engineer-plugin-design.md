# Design: claude-engineer — Merged Skills Plugin

## Goal

A standalone Claude Code plugin that combines superpowers' orchestration (brainstorm → plan → execute → review) with agent-skills' engineering standards (anti-rationalizations, OWASP, Hyrum's Law, 5-axis review). Replaces both plugins — neither should be installed alongside this one.

## Core Principle

**The user says "I want to build X" and the plugin drives the entire lifecycle automatically.** No slash commands needed. Skills chain via explicit handoffs. Domain-specific practices auto-trigger based on context.

---

## Orchestration Chain

```
User prompt ("I want to build X...")
  │
  ▼
① brainstorming
   Outputs: design spec
   Handoff: → writing-plans
  │
  ▼
② writing-plans
   Outputs: implementation plan
   Handoff: → subagent-driven-development (or executing-plans)
  │
  ▼
③ subagent-driven-development
   Setup: using-git-worktrees
   Per task:
     a. Dispatch implementer (follows TDD + incremental-implementation)
        - Domain skills auto-trigger: api-and-interface-design, frontend-ui-engineering,
          security-and-hardening, etc.
     b. Implementer self-reviews + runs tests (verification-before-completion)
     c. Spec compliance review
     d. Code quality review (5-axis framework + security + performance)
   After all tasks: run full test suite + self-review
   Handoff: → requesting-code-review
  │
  ▼
④ requesting-code-review
   Dispatch code-reviewer agent (5-axis)
   If issues → receiving-code-review → fix → re-review
   Handoff: → finishing-a-development-branch
  │
  ▼
⑤ finishing-a-development-branch
   Run tests → present options (merge/PR/keep/discard) → cleanup
```

At any point during BUILD, if something breaks:
→ systematic-debugging activates

---

## Skill Inventory (23 skills)

### A. Chain Skills (6) — drive the flow via explicit handoffs

| # | Skill | Source | What's merged in |
|---|---|---|---|
| 1 | brainstorming | superpowers base | + idea-refine divergent/convergent thinking, + spec-driven-development PRD structure, + "surface assumptions" behavior, + anti-rationalizations |
| 2 | writing-plans | superpowers base | + planning-and-task-breakdown vertical slicing, dependency graphs, acceptance criteria, + anti-rationalizations |
| 3 | subagent-driven-development | superpowers base | + incremental-implementation thin-slice instructions for implementers, + post-completion test suite + self-review before final reviewer |
| 4 | executing-plans | superpowers (as-is) | Alternative to subagent-driven |
| 5 | requesting-code-review | superpowers base | + 5-axis review framework (correctness, readability, architecture, security, performance), + change sizing |
| 6 | finishing-a-development-branch | superpowers base | + atomic commit principles, + pre-merge checklist from shipping-and-launch |

### B. Domain Skills (10) — auto-triggered during BUILD

| Skill | Source | Auto-triggers when... |
|---|---|---|
| test-driven-development | agent-skills | Implementing any logic or fixing bugs |
| incremental-implementation | agent-skills | Task touches multiple files |
| api-and-interface-design | agent-skills | Designing APIs, endpoints, module boundaries |
| frontend-ui-engineering | agent-skills | Building/modifying UI |
| security-and-hardening | agent-skills | Handling user input, auth, external data |
| performance-optimization | agent-skills | Performance requirements or regressions |
| source-driven-development | agent-skills | Using frameworks/libraries |
| code-simplification | agent-skills | Refactoring for clarity |
| documentation-and-adrs | agent-skills | Making architectural decisions |
| browser-testing-with-devtools | agent-skills | Browser-based debugging |

### C. Support Skills (6) — invoked by other skills

| Skill | Source | Used by |
|---|---|---|
| systematic-debugging | superpowers base + agent-skills anti-rationalizations | Any skill when something breaks |
| verification-before-completion | superpowers | Every skill before claiming done |
| receiving-code-review | superpowers | After code review feedback |
| using-git-worktrees | superpowers | subagent-driven-development setup |
| dispatching-parallel-agents | superpowers | Multiple independent problems |
| context-engineering | agent-skills | Session start, context degradation |

### D. Meta (1)

| Skill | Purpose |
|---|---|
| using-skills | Session start routing — decides which chain/skill to activate |

---

## Supporting Files

### Agent Personas (from agent-skills)

- `agents/code-reviewer.md` — Senior Staff Engineer, 5-axis review
- `agents/test-engineer.md` — QA Specialist, test strategy and coverage
- `agents/security-auditor.md` — Security Engineer, OWASP and threat modeling

### Reference Checklists (from agent-skills)

- `references/security-checklist.md` — Pre-commit, auth, input validation, CORS, OWASP Top 10
- `references/performance-checklist.md` — Core Web Vitals, frontend/backend checklists
- `references/testing-patterns.md` — Test structure, naming, mocking, anti-patterns
- `references/accessibility-checklist.md` — Keyboard nav, screen readers, WCAG 2.1 AA

### Slash Commands (optional shortcuts)

- `/spec` → brainstorming
- `/plan` → writing-plans
- `/build` → subagent-driven-development
- `/test` → test-driven-development
- `/review` → requesting-code-review
- `/simplify` → code-simplification
- `/ship` → finishing-a-development-branch
- `/debug` → systematic-debugging

---

## What Each Merged Skill Contains

### Enrichment pattern for chain skills

Each chain skill gets enriched with agent-skills' standard sections:

1. **Process** — superpowers' orchestration steps (kept as-is)
2. **Anti-Rationalizations table** — from agent-skills (catches when Claude tries to skip steps)
3. **Red Flags** — from agent-skills (warning signs of misapplication)
4. **Verification** — from agent-skills (concrete evidence requirements)
5. **Handoff** — superpowers' explicit "invoke [next skill]" instruction

### Specific merges

**brainstorming = superpowers brainstorming + agent-skills idea-refine + spec-driven-development**
- Keep: superpowers' question flow, design sections, visual companion, spec self-review, user review gate
- Add: idea-refine's Phase 1 (diverge: 5+ alternatives) and Phase 2 (converge: evaluate against criteria)
- Add: spec-driven-development's PRD structure (objectives, structure, testing strategy, boundaries)
- Add: "surface assumptions" and "manage confusion actively" behaviors from using-agent-skills
- Add: anti-rationalization table (e.g., "Requirements are obvious" → "Unwritten requirements are unvalidated assumptions")
- Handoff: "Invoke writing-plans"

**writing-plans = superpowers writing-plans + agent-skills planning-and-task-breakdown**
- Keep: superpowers' bite-sized tasks, checkbox syntax, no-placeholders rule, TDD ordering, self-review
- Add: vertical slicing principle ("one complete path per task, not horizontal layers")
- Add: dependency graph identification
- Add: checkpoint placement between phases
- Add: anti-rationalization table (e.g., "This is too small to plan" → "Small tasks with wrong order waste more time than planning costs")
- Handoff: "Choose subagent-driven-development or executing-plans"

**subagent-driven-development = superpowers subagent-driven-development + incremental-implementation**
- Keep: fresh subagent per task, two-stage review (spec then quality), model selection strategy, all escalation paths
- Add: implementer instructions reference incremental-implementation's thin-slice approach
- Add: after all tasks complete, NEW step: run full test suite + self-review BEFORE dispatching final code reviewer
- Add: anti-rationalization table for skipping reviews
- Handoff: "Invoke requesting-code-review"

**requesting-code-review = superpowers requesting-code-review + agent-skills code-review-and-quality**
- Keep: superpowers' SHA-based dispatch, act-on-feedback protocol
- Add: 5-axis review framework as instructions for the code-reviewer agent
- Add: change sizing guidance (~100 lines per review)
- Add: security-and-hardening and performance-optimization as sub-checks
- Handoff: "Invoke finishing-a-development-branch"

**finishing-a-development-branch = superpowers finishing-a-development-branch + git-workflow + shipping-and-launch**
- Keep: superpowers' test verification, 4 options, worktree cleanup
- Add: atomic commit principle from git-workflow-and-versioning
- Add: pre-merge checklist items from shipping-and-launch (no TODOs, no console.log, error handling covers failure modes)
- Terminal skill

**systematic-debugging = superpowers systematic-debugging + agent-skills debugging-and-error-recovery**
- Keep: superpowers' 4-phase process (root cause, pattern, hypothesis, implementation)
- Add: agent-skills' anti-rationalization table ("Quick fix for now" → "Quick fixes become permanent. Find the root cause")
- Add: "Guard" step — after fix, add test/monitoring to prevent recurrence
- Add: red flags section

---

## Plugin File Structure

```
claude-engineer/
  plugin.json
  CLAUDE.md
  skills/
    # Chain
    brainstorming/SKILL.md
    writing-plans/SKILL.md
    subagent-driven-development/SKILL.md
      implementer-prompt.md
      spec-reviewer-prompt.md
      code-quality-reviewer-prompt.md
    executing-plans/SKILL.md
    requesting-code-review/SKILL.md
    receiving-code-review/SKILL.md
    finishing-a-development-branch/SKILL.md
    # Domain (from agent-skills)
    test-driven-development/SKILL.md
    incremental-implementation/SKILL.md
    api-and-interface-design/SKILL.md
    frontend-ui-engineering/SKILL.md
    security-and-hardening/SKILL.md
    performance-optimization/SKILL.md
    source-driven-development/SKILL.md
    code-simplification/SKILL.md
    documentation-and-adrs/SKILL.md
    browser-testing-with-devtools/SKILL.md
    # Support
    systematic-debugging/SKILL.md
    verification-before-completion/SKILL.md
    using-git-worktrees/SKILL.md
    dispatching-parallel-agents/SKILL.md
    context-engineering/SKILL.md
    writing-skills/SKILL.md
    # Meta
    using-skills/SKILL.md
  agents/
    code-reviewer.md
    test-engineer.md
    security-auditor.md
  references/
    security-checklist.md
    performance-checklist.md
    testing-patterns.md
    accessibility-checklist.md
  hooks/
    session-start.sh
  .claude/commands/
    spec.md
    plan.md
    build.md
    test.md
    review.md
    simplify.md
    ship.md
    debug.md
```

---

## What's NOT Included (and why)

| Dropped | Reason |
|---|---|
| agent-skills' idea-refine | Merged into brainstorming |
| agent-skills' spec-driven-development | Merged into brainstorming |
| agent-skills' planning-and-task-breakdown | Merged into writing-plans |
| agent-skills' code-review-and-quality | Merged into requesting-code-review |
| agent-skills' debugging-and-error-recovery | Merged into systematic-debugging |
| agent-skills' git-workflow-and-versioning | Merged into finishing-a-development-branch |
| agent-skills' shipping-and-launch | Pre-merge items merged into finishing-a-development-branch; full launch checklist available as reference |
| agent-skills' ci-cd-and-automation | Too project-specific; add later if needed |
| agent-skills' deprecation-and-migration | Niche; add later if needed |
| agent-skills' using-agent-skills | Replaced by using-skills |
| superpowers' using-superpowers | Replaced by using-skills |
| superpowers' writing-skills | Kept (meta skill for authoring new skills) |

---

## Portability

- Published as a git repo (e.g., `github.com/oscarqjh/claude-engineer`)
- Install on any machine: `git clone` + `claude --plugin-dir ./claude-engineer`
- Or publish to Claude Code plugin marketplace for `/plugin install`
- No dependency on superpowers or agent-skills being installed
- Self-contained: all skills, agents, references, commands in one repo

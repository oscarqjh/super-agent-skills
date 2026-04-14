# Super-Agent-Skills Architecture

## Core Principle

**One command. Full lifecycle. No shortcuts.**

This plugin is opinionated: it believes that every piece of software — from a single function to a full-stack feature — benefits from a structured process. Not because process is good for its own sake, but because unstructured work produces unstructured output.

The plugin enforces this through three mechanisms:

1. **Skill chaining** — each skill hands off to the next automatically. You can't accidentally skip the spec, skip the tests, or skip the review.
2. **Anti-rationalization tables** — every skill includes a table catching the excuses agents use to skip steps. "Requirements are obvious" → "Unwritten requirements are unvalidated assumptions."
3. **Hooks** — deterministic enforcement at key boundaries. The agent can't silently commit without prompting you. Commands that fail suggest adding gotchas to CLAUDE.md.

The result: you type `/superthink build me X` and get shipped, reviewed, tested, documented code — not a pile of uncommitted files.

---

## The Complete Process Graph

### Entry Point: /superthink

```
User types /superthink [intent]
        │
        ▼
┌─────────────────────────────────┐
│  INTENT CLASSIFICATION          │
│  (superthink command)           │
│                                 │
│  Reads user's prompt and        │
│  classifies into one of 7       │
│  workflows                      │
└────────┬────────────────────────┘
         │
         ├── BUILD ──────────────────── Full orchestration chain (see below)
         │   "build X", "create X",
         │   "add X", "I want to..."
         │
         ├── FIX ────────────────────── systematic-debugging
         │   "fix X", "bug", "broken"
         │
         ├── REVIEW ─────────────────── requesting-code-review
         │   "review", "check code"
         │
         ├── TEST ───────────────────── test-driven-development
         │   "test X", "TDD"
         │
         ├── SIMPLIFY ───────────────── code-simplification
         │   "simplify", "refactor"
         │
         ├── SHIP ───────────────────── finishing-a-development-branch
         │   "ship", "merge", "PR"
         │
         ├── PLAN ───────────────────── writing-plans
         │   "plan X", "break down"
         │
         └── UNCLEAR ────────────────── asks ONE clarifying question
```

---

### The BUILD Chain (Full Lifecycle)

This is the primary workflow. Each box is a skill. Arrows show automatic handoffs.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  ① BRAINSTORMING                                                       │
│  Skill: brainstorming                                                   │
│                                                                         │
│  What it does:                                                          │
│  - Explores project context (files, docs, commits)                      │
│  - Asks clarifying questions one at a time                              │
│  - Generates 5-8 idea variations (divergent thinking)                   │
│  - Proposes 2-3 approaches with trade-offs (convergent thinking)        │
│  - Presents design section by section for approval                      │
│  - Writes design spec to docs/super-agent-skills/specs/                 │
│  - Generates acceptance test skeletons (Given/When/Then)                │
│  - Updates backlog                                                      │
│                                                                         │
│  Triggers if security-sensitive:                                        │
│  └── threat-modeling (STRIDE analysis before finalizing design)         │
│                                                                         │
│  Output: approved design spec with acceptance tests                     │
│                                                                         │
│  Handoff: → writing-plans                                               │
│                                                                         │
└────────────────────────────┬────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  ② WRITING PLANS                                                        │
│  Skill: writing-plans                                                   │
│                                                                         │
│  What it does:                                                          │
│  - Maps dependency graph (what depends on what)                         │
│  - Slices vertically (one complete feature path per task)               │
│  - Writes bite-sized tasks with exact code, commands, expected output   │
│  - Incorporates acceptance tests from spec into task steps              │
│  - Adds checkpoints between phases                                      │
│  - Self-reviews plan against spec                                       │
│                                                                         │
│  If multi-stream feature detected:                                      │
│  └── suggests compound-engineering for parallel execution               │
│                                                                         │
│  Output: implementation plan in docs/super-agent-skills/plans/          │
│                                                                         │
│  Handoff: → subagent-driven-development (or executing-plans)            │
│                                                                         │
└────────────────────────────┬────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  ③ SUBAGENT-DRIVEN DEVELOPMENT                                          │
│  Skill: subagent-driven-development                                     │
│                                                                         │
│  What it does (per task):                                               │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │ a. Dispatch implementer subagent (fresh context per task)        │   │
│  │    - Follows TDD (red-green-refactor)                            │   │
│  │    - Follows incremental-implementation (thin slices)            │   │
│  │    - Domain skills auto-trigger based on task:                   │   │
│  │      ├── API work → api-and-interface-design                     │   │
│  │      ├── UI work → frontend-ui-engineering                       │   │
│  │      ├── Auth/input → security-and-hardening                     │   │
│  │      ├── Perf work → performance-optimization                    │   │
│  │      ├── Framework use → source-driven-development               │   │
│  │      └── Architecture decisions → documentation-and-adrs         │   │
│  │                                                                  │   │
│  │ b. Spec compliance review (spec-reviewer agent)                  │   │
│  │    Did the implementer build what was requested?                 │   │
│  │    Missing requirements? Extra unneeded work?                    │   │
│  │                                                                  │   │
│  │ c. Code quality review (code-reviewer agent)                     │   │
│  │    5-axis: correctness, readability, architecture,               │   │
│  │    security, performance                                         │   │
│  │    Additional agents if needed:                                  │   │
│  │      ├── architecture-reviewer (design decisions)                │   │
│  │      ├── test-generator (large test suites)                      │   │
│  │      └── dependency-auditor (supply chain)                       │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  Parallel dispatch: if tasks have zero file overlap,                    │
│  dispatches up to 3 implementers simultaneously                         │
│                                                                         │
│  After ALL tasks: runs full test suite + self-review                    │
│                                                                         │
│  Handoff: → requesting-code-review                                      │
│                                                                         │
└────────────────────────────┬────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  ④ REQUESTING CODE REVIEW                                               │
│  Skill: requesting-code-review                                          │
│                                                                         │
│  What it does:                                                          │
│  - Dispatches code-reviewer agent with git diff context                 │
│  - 5-axis review: correctness, readability, architecture,               │
│    security, performance                                                │
│  - Architecture-significant changes also get architecture-reviewer      │
│  - Self-healing loop: if issues found, auto-dispatches fix agent,       │
│    re-reviews (up to 3 rounds)                                          │
│  - Review sizing gate: blocks reviews >1000 lines (must split)          │
│                                                                         │
│  Agents dispatched:                                                     │
│  ├── code-reviewer (always)                                             │
│  ├── architecture-reviewer (if design changes)                          │
│  ├── security-auditor (if security-sensitive)                           │
│  └── test-engineer (if test quality concerns)                           │
│                                                                         │
│  Hook: skill-scoped Stop hook prevents silent completion                │
│  Hook: SubagentStop fires after code-reviewer completes                 │
│                                                                         │
│  Output: approved review with all issues resolved                       │
│                                                                         │
│  Handoff: → USER PROMPT (see below)                                     │
│                                                                         │
└────────────────────────────┬────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  ⑤ USER PROMPT — "Review passed. What next?"                            │
│                                                                         │
│  The agent MUST ask. It cannot skip this.                               │
│                                                                         │
│  A) Wrap up ─────────→ wrap-up skill                                    │
│     Update backlog, changelog, commit, suggest next item                │
│     (For single-branch workflows / checkpointing progress)              │
│                                                                         │
│  B) Ship it ─────────→ finishing-a-development-branch skill             │
│     Pre-merge checklist, merge/PR/keep/discard options, cleanup         │
│     (For feature branches / worktree workflows)                         │
│                                                                         │
│  C) Keep going ──────→ back to implementation                           │
│     More changes needed before wrapping up                              │
│                                                                         │
│  D) Specific instruction → agent follows it                             │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

### At Any Point: Support Skills

These activate automatically when needed during any phase:

```
During ANY phase:
│
├── Something breaks → systematic-debugging
│   4 phases: root cause → pattern analysis → hypothesis → implementation
│   Guard against recurrence (write a test)
│   Stop-the-line rule (stop features, fix the bug)
│
├── About to claim "done" → verification-before-completion
│   No completion claims without fresh verification evidence
│   Run the command, read the output, THEN claim the result
│
├── Code review feedback received → receiving-code-review
│   Evaluate feedback technically, don't blindly agree
│   Push back on incorrect suggestions with evidence
│
├── Need isolated workspace → using-git-worktrees
│   Create worktree with smart directory selection
│   Safety verification (check .gitignore)
│
├── Multiple independent problems → dispatching-parallel-agents
│   Dispatch agents in parallel for unrelated tasks
│
├── Context degrading → context-engineering
│   Mid-session compaction, tiered memory model
│   Cross-session persistence, recovery pattern
│
└── Writing new skills → writing-skills
    TDD approach for skill authoring
```

---

### The Hook System

Hooks fire at lifecycle boundaries to enforce discipline:

```
SessionStart
├── Loads using-skills meta skill (skill routing)
└── Checks for CLAUDE.md → prompts project-setup if missing

PreToolUse (on Bash)
└── If git push → reminds about finishing-a-development-branch

SubagentStop (on code-reviewer)
└── Injects prompt: "Present A/B/C completion options to user"

PostToolUseFailure (on Bash)
└── If command failed → suggests adding gotcha to CLAUDE.md

Stop (scoped to requesting-code-review)
└── Blocks silent completion → forces user prompt
```

---

## Skill Inventory

### Chain Skills (6) — drive the orchestration flow

| Skill | Trigger | Output |
|-------|---------|--------|
| brainstorming | "I want to build X" | Design spec with acceptance tests |
| writing-plans | Spec approved | Implementation plan with bite-sized tasks |
| subagent-driven-development | Plan ready | Working, tested, reviewed code |
| executing-plans | Plan ready (no subagents) | Working code (inline execution) |
| requesting-code-review | Implementation complete | Approved review |
| finishing-a-development-branch | User chooses "ship it" | Merged/PR'd code |

### Domain Skills (10) — auto-trigger during implementation

| Skill | Triggers when... |
|-------|-----------------|
| test-driven-development | Implementing any logic or fixing bugs |
| incremental-implementation | Task touches multiple files |
| api-and-interface-design | Designing APIs, endpoints, module boundaries |
| frontend-ui-engineering | Building or modifying UI |
| security-and-hardening | Handling user input, auth, external data |
| performance-optimization | Performance requirements or regressions |
| source-driven-development | Using frameworks or libraries |
| code-simplification | Refactoring for clarity |
| documentation-and-adrs | Making architectural decisions |
| browser-testing-with-devtools | Browser-based debugging |

### Build Skills (3) — specialized workflows

| Skill | What it does |
|-------|-------------|
| compound-engineering | Orchestrate multi-stream parallel development across worktrees |
| threat-modeling | STRIDE-based proactive security design before implementation |
| project-setup | Scan codebase, generate lean CLAUDE.md, organic growth |

### Support Skills (8) — invoked by other skills

| Skill | Used when... |
|-------|-------------|
| systematic-debugging | Something breaks during any phase |
| verification-before-completion | About to claim work is done |
| receiving-code-review | Processing review feedback |
| using-git-worktrees | Need isolated workspace |
| dispatching-parallel-agents | Multiple independent problems |
| context-engineering | Context degrading mid-session |
| writing-skills | Authoring new skills |
| wrap-up | Checkpoint progress (backlog, changelog, commit, next item) |

### Meta Skills (2) — routing and auditing

| Skill | What it does |
|-------|-------------|
| using-skills | Session-start routing — matches tasks to skills |
| plugin-audit | Check for plugin conflicts, suggest complements |

### Agent Personas (7)

| Agent | Dispatched by | Role |
|-------|--------------|------|
| code-reviewer | requesting-code-review | 5-axis code quality evaluation |
| test-engineer | requesting-code-review | Test strategy and coverage analysis |
| security-auditor | requesting-code-review | Vulnerability detection, OWASP |
| architecture-reviewer | requesting-code-review | Design decision evaluation, coupling, Hyrum's Law |
| test-generator | test-driven-development | Autonomous test suite generation from specs |
| dependency-auditor | security-and-hardening | Supply chain audit (security, licenses, maintenance) |
| migration-assistant | using-skills routing | Framework/library migration planning |

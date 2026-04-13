# super-agent-skills

A standalone Claude Code plugin that combines orchestration (brainstorm → plan → execute → review → ship) with production-grade engineering standards (anti-rationalizations, 5-axis code review, OWASP, Hyrum's Law, TDD).

## Getting Started

1. Install the plugin:
   ```bash
   # Add the marketplace and install (two steps)
   /plugin marketplace add oscarqjh/super-agent-skills
   /plugin install super-agent-skills@oscarqjh-super-agent-skills

   # Or clone and add locally
   git clone https://github.com/oscarqjh/super-agent-skills.git
   claude plugin add -- ./super-agent-skills
   ```

2. Use `/superthink` followed by what you want to do:
   ```
   /superthink I want to build a task management API
   /superthink fix the authentication bug in login.ts
   /superthink review my changes before merging
   /superthink simplify the auth module
   ```

That's it. The plugin understands your intent, gathers project context, and routes to the right workflow automatically.

> **Replaces** both `superpowers` and `agent-skills`. Do not install either alongside this plugin.

### Other Environments

Not using Claude Code? See the setup guide for your tool:

| Environment | Guide |
|-------------|-------|
| **Claude Code** | [docs/claude-code-setup.md](docs/claude-code-setup.md) |
| **Cursor** | [docs/cursor-setup.md](docs/cursor-setup.md) |
| **OpenCode** | [docs/opencode-setup.md](docs/opencode-setup.md) |
| **Gemini CLI** | [docs/gemini-cli-setup.md](docs/gemini-cli-setup.md) |
| **Windsurf** | [docs/windsurf-setup.md](docs/windsurf-setup.md) |
| **GitHub Copilot** | [docs/copilot-setup.md](docs/copilot-setup.md) |
| **Any agent** | [docs/getting-started.md](docs/getting-started.md) |

## What Happens When You Run `/superthink`

The plugin classifies your intent and routes accordingly:

| You say... | Plugin does... |
|-----------|---------------|
| "build X", "create X", "add X", "I want to..." | Full chain: brainstorm → plan → build → review → ship |
| "fix X", "bug in X", "X is broken" | Systematic debugging (root cause first) |
| "review my code", "check before merging" | 5-axis code review |
| "test X", "write tests for X" | TDD workflow (red-green-refactor) |
| "simplify X", "refactor X", "clean up X" | Code simplification |
| "ship it", "merge", "create PR" | Pre-merge checklist + merge/PR options |
| "plan X", "break down X" | Task breakdown with dependency graphs |

### The Full Build Chain

When you're building something new, the plugin runs the complete lifecycle automatically:

```
/superthink I want to build X
        │
        ▼
  ① brainstorming ──────────── design spec
        │
        ▼
  ② writing-plans ─────────── implementation plan
        │
        ▼
  ③ subagent-driven-development
     │  Per task:
     │   a. Dispatch implementer (TDD + incremental)
     │   b. Domain skills auto-trigger (API, frontend, security...)
     │   c. Spec compliance review
     │   d. Code quality review (5-axis)
     │  After all tasks: full test suite + self-review
        │
        ▼
  ④ requesting-code-review ── 5-axis review
        │
        ▼
  ⑤ finishing-a-development-branch ── merge / PR / cleanup
```

At any point, if something breaks → `systematic-debugging` activates.

## Expert Shortcuts

If you know exactly which phase you need, skip the routing:

| Command | Jumps to |
|---------|----------|
| `/spec` | Brainstorming — design exploration and spec writing |
| `/plan` | Writing plans — task breakdown with vertical slicing |
| `/build` | Subagent-driven development — execute a plan |
| `/test` | TDD — red-green-refactor cycle |
| `/review` | Code review — 5-axis evaluation |
| `/simplify` | Code simplification — reduce complexity |
| `/ship` | Finish branch — pre-merge checklist, merge/PR |
| `/debug` | Systematic debugging — root cause investigation |

## Skills (24)

### Chain Skills (6) — drive the orchestration flow

| Skill | What it does |
|-------|-------------|
| `brainstorming` | Explore ideas with divergent/convergent thinking, produce design spec |
| `writing-plans` | Break spec into bite-sized tasks with dependency graphs and vertical slicing |
| `subagent-driven-development` | Execute plan via fresh subagent per task with two-stage review |
| `executing-plans` | Alternative inline execution (no subagents) |
| `requesting-code-review` | Dispatch 5-axis code review (correctness, readability, architecture, security, performance) |
| `finishing-a-development-branch` | Pre-merge checklist, atomic commits, merge/PR/keep/discard options |

### Domain Skills (10) — auto-trigger during implementation

| Skill | Triggers when... |
|-------|-----------------|
| `test-driven-development` | Implementing any logic or fixing bugs |
| `incremental-implementation` | Task touches multiple files |
| `api-and-interface-design` | Designing APIs, endpoints, module boundaries |
| `frontend-ui-engineering` | Building or modifying UI |
| `security-and-hardening` | Handling user input, auth, external data |
| `performance-optimization` | Performance requirements or regressions |
| `source-driven-development` | Using frameworks or libraries |
| `code-simplification` | Refactoring for clarity |
| `documentation-and-adrs` | Making architectural decisions |
| `browser-testing-with-devtools` | Browser-based debugging |

### Support Skills (7) — invoked by other skills

| Skill | Used by |
|-------|---------|
| `systematic-debugging` | Any skill when something breaks |
| `verification-before-completion` | Every skill before claiming done |
| `receiving-code-review` | After code review feedback |
| `using-git-worktrees` | Isolated workspace setup |
| `dispatching-parallel-agents` | Multiple independent problems |
| `context-engineering` | Session start, context management |
| `writing-skills` | Authoring new skills for plugins |

### Meta (1)

| Skill | Purpose |
|-------|---------|
| `using-skills` | Session-start routing — decides which skill to activate |

## What's Included

```
super-agent-skills/
├── .claude-plugin/plugin.json     Plugin metadata
├── CLAUDE.md                      Plugin conventions
├── skills/                        24 skills (SKILL.md each)
│   ├── brainstorming/             + visual companion, scripts
│   ├── writing-plans/             + plan reviewer prompt
│   ├── subagent-driven-development/ + implementer, spec, quality prompts
│   ├── systematic-debugging/      + root-cause tracing, defense-in-depth
│   ├── writing-skills/            + best practices, testing guides
│   └── ...
├── agents/                        3 subagent personas
│   ├── code-reviewer.md           Senior Staff Engineer, 5-axis review
│   ├── test-engineer.md           QA Specialist, test strategy
│   └── security-auditor.md        Security Engineer, OWASP
├── references/                    4 checklists
│   ├── security-checklist.md      OWASP Top 10, input validation, CORS
│   ├── performance-checklist.md   Core Web Vitals, frontend/backend
│   ├── testing-patterns.md        AAA pattern, mocking, E2E
│   └── accessibility-checklist.md WCAG 2.1 AA
├── commands/                      9 slash commands
└── hooks/                         Session-start hook
```

## What Makes This Different

Every chain skill includes:

- **Process** — orchestration steps with explicit handoffs
- **Anti-Rationalizations** — catches when Claude tries to skip steps ("Requirements are obvious" → "Unwritten requirements are unvalidated assumptions")
- **Red Flags** — warning signs of misapplication
- **Verification** — concrete evidence requirements before claiming done

Domain skills enforce engineering standards:

- TDD with red-green-refactor discipline
- Vertical slicing over horizontal layers
- Security-first with OWASP prevention
- Measure-first performance optimization
- Hyrum's Law awareness in API design

## Credits

Built by merging and extending:
- [superpowers](https://github.com/obra/superpowers) by Jesse Vincent — orchestration and workflow skills
- [agent-skills](https://github.com/addyosmani/agent-skills) by Addy Osmani — engineering standards and domain skills

## License

MIT

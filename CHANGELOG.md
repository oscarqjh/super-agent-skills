# Changelog

All notable changes to the super-agent-skills plugin. For detailed development history, see [docs/super-agent-skills/changelog.md](docs/super-agent-skills/changelog.md).

## [1.1.3] — 2026-04-21

### Removed
- **Stop hook in `requesting-code-review/SKILL.md` frontmatter** — this hook emitted an unconditional `decision: block` on every parent-agent turn with no `stop_hook_active` guard and no exit condition, producing the exact "Before stopping, you must prompt the user with completion options…" infinite loop users reported. Previous v1.1.1/v1.1.2 fixes addressed only the SubagentStop hook in `hooks/hooks.json`; this skill-frontmatter hook was a separate, parallel enforcement layer that was missed.
- **SubagentStop hook in `hooks/hooks.json`** — the sentinel-gated subagent-layer enforcement is also removed. Blocking agent-stop to enforce a UX nudge is the wrong primitive: every flag/sentinel/timestamp-based gating scheme has edge cases (user takes multiple turns to decide, summarization drops the sentinel, interrupt orphans state) that reintroduce loop risk for marginal safety.
- `hooks/code-reviewer-stop.js` + `hooks/code-reviewer-stop.test.sh` — obsolete once the SubagentStop hook is gone.
- **Completion Protocol section** in `agents/code-reviewer.md` — the `[AWAITING_USER_CHOICE]` sentinel contract is no longer needed without the hook that consumed it.

### Rationale
The A/B/C completion menu is a conversation-flow concern, not a work-completion gate. `requesting-code-review/SKILL.md` still contains the menu prose in its `## Handoff` section and a `<HARD-GATE>` block instructing the agent not to commit/push without prompting the user first. We now rely on that prose + the existing SessionStart context injection to shape behavior, rather than blocking hooks at either layer. If drift becomes a real problem in practice, the correct next step is a `UserPromptSubmit` hook that routes the user's A/B/C reply — observable enforcement at the input layer, never the output layer.

## [1.1.2] — 2026-04-19

### Changed
- **Sentinel-based SubagentStop detection** — the code-reviewer completion hook now matches a literal `[AWAITING_USER_CHOICE]` sentinel instead of a permissive `A) … B) … C)` regex. The previous regex produced false positives on incidental prose (e.g. a review that listed `A) foo.ts, B) bar.ts, C) baz.ts` among affected files), silently bypassing the hook.
- The `code-reviewer` agent now ends every response with the sentinel followed by the A/B/C menu, per a new Completion Protocol in `agents/code-reviewer.md`. The hook's block reason teaches the exact sentinel + menu, so a forgetful agent self-heals on the next pass.

### Added
- `hooks/code-reviewer-stop.test.sh` — fixture-based smoke tests covering malformed JSON, empty stdin, `stop_hook_active`, sentinel present, sentinel absent, incidental A/B/C prose, and missing `last_assistant_message`.
- stdin `error` listener in `code-reviewer-stop.js` — an EPIPE or read error now exits 0 instead of surfacing a non-zero exit (which the harness would treat as a block, reintroducing loop risk).

### Fixed
- `hooks.json` `SubagentStop` key indentation aligned with siblings.

## [1.1.1] — 2026-04-19

### Fixed
- **SubagentStop hook loop** — code-reviewer completion-prompt hook rewritten as a command-type hook with `stop_hook_active` guard and A/B/C detection. The previous `type: "prompt"` variant could re-fire on every stop attempt, trapping the agent in an infinite "Before stopping, you must prompt the user…" loop. New `hooks/code-reviewer-stop.js` emits `decision: "block"` only when options are genuinely missing, exits silently otherwise.

## [1.1.0] — 2026-04-18

### Added
- **Execution route system** — `/superthink` rewritten as a 3-stage routing pipeline (decompose → match → build route). 14 intent routes (up from 7): adds OPTIMIZE, SECURE, DOCUMENT, SETUP, AUDIT, CONTEXT, THREAT-MODEL. HARD-GATE chain enforcement via TaskCreate persistence. CHECK BACKLOG terminal step. Multi-intent decomposition ("fix then test" → merged route).
- **Capability awareness system** — Structured YAML frontmatter on all 29 skills (phase, produces, requires, companions, chainsTo, autoTriggers). Auto-generated capability index from frontmatter. Session-start hook injects capability summary. Cytoscape routing graph visualization.
- **Cost-optimized delegation** — 3 prompt templates (spec-writer, spec-reviewer, plan-writer) delegating spec/plan writing to sonnet subagents. Explicit model selection table in subagent-driven-development. Inline vs delegated boundary in writing-plans.
- **code-explorer agent** — read-only codebase analysis (traces execution paths, maps architecture, documents dependencies). Dispatched conditionally during brainstorming.
- **code-architect agent** — architecture blueprint generation (analyzes patterns, designs implementation blueprints). Dispatched during writing-plans.
- **3-option execution handoff** in writing-plans — detects independent streams and offers compound (parallel worktrees), subagent-driven (sequential), or inline execution.
- Structural + LLM behavioral test suites (34 execution-route tests, 34 agent-integration tests, 22 capability/awareness tests).

### Changed
- **Repo restructured as multi-plugin marketplace** (`plugins/<name>/`).
- Compound-engineering integrated into writing-plans handoff. Trimmed from 5 phases to 3 (execute/integrate/review) — decomposition and planning now handled upstream.
- 5 skills trimmed for token efficiency (~2,790 words removed, ~22% average reduction): writing-skills, test-driven-development, brainstorming, context-engineering, security-and-hardening.
- Workflow chain graph simplified — compound-engineering now a choice from writing-plans rather than a separate entry point.
- Cross-references added between related skills (threat-modeling ↔ security-and-hardening, requesting-code-review ↔ receiving-code-review).

## [1.0.3] — 2026-04-14

### Added
- Session learning capture in wrap-up and finishing-a-development-branch (5 friction signals → CLAUDE.md/rules)
- CONTRIBUTING.md, example workflows, skill authoring guide
- CHANGELOG.md (public release changelog at root)
- .gitignore for internal development artifacts

### Fixed
- Removed PreToolUse hook entirely (prompt-type hooks block instead of advising)

## [1.0.2] — 2026-04-14

### Fixed
- PreToolUse git push hook now advisory (no longer blocks non-feature pushes)
- Removed disable-model-invocation from plugin-audit and project-setup skills (commands blocked skill invocation)

## [1.0.0] — 2026-04-14

First stable release.

### Added
- **29 skills** covering the full development lifecycle: brainstorm → plan → build → review → ship
- **7 agent personas**: code-reviewer, test-engineer, security-auditor, architecture-reviewer, test-generator, dependency-auditor, migration-assistant
- **6 reference guides**: security, performance, testing, accessibility, supply-chain security, MCP integrations
- **12 slash commands** including `/superthink` universal entry point, `/wrapup`, `/project-setup`, `/audit`
- **4 hook types**: SessionStart (meta skill + CLAUDE.md check), PreToolUse (git push advisory), SubagentStop (post-review prompt), PostToolUseFailure (CLAUDE.md gotcha suggestions)
- Orchestration chain with user prompt after review (wrap up / ship it / keep going)
- Selective parallel dispatch for independent tasks (max 3 agents)
- Spec-driven test generation from acceptance criteria
- 5-axis code review with self-healing fix loop (3 rounds)
- STRIDE threat modeling for security-sensitive features
- Compound engineering for multi-stream parallel development
- Project setup with organic CLAUDE.md growth
- Plugin audit for conflict detection and MCP suggestions
- Multi-environment setup docs (Claude Code, Cursor, OpenCode, Gemini, Windsurf, Copilot)

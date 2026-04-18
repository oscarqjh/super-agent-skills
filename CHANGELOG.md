# Changelog

All notable changes to the super-agent-skills plugin. For detailed development history, see [docs/super-agent-skills/changelog.md](docs/super-agent-skills/changelog.md).

## [1.1.0] — 2026-04-18

### Added
- **code-explorer agent** — read-only codebase analysis (traces execution paths, maps architecture, documents dependencies). Dispatched conditionally during brainstorming.
- **code-architect agent** — architecture blueprint generation (analyzes patterns, designs implementation blueprints). Dispatched during writing-plans.
- **3-option execution handoff** in writing-plans — detects independent streams and offers compound (parallel worktrees), subagent-driven (sequential), or inline execution.
- 34-test structural test suite for agent integration.

### Changed
- Compound-engineering integrated into writing-plans handoff. Trimmed from 5 phases to 3 (execute/integrate/review) — decomposition and planning now handled upstream.
- 5 skills trimmed for token efficiency (~2,790 words removed, ~22% average reduction): writing-skills, test-driven-development, brainstorming, context-engineering, security-and-hardening.
- Workflow chain graph simplified — compound-engineering now a choice from writing-plans rather than a separate entry point.

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

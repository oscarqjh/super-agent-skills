# Changelog

All notable changes to the super-agent-skills plugin.

Format follows [Keep a Changelog](https://keepachangelog.com/).

## [1.0.0] — 2026-04-14

First stable release. Full-lifecycle engineering skills plugin with orchestration chain, 29 skills, 7 agents, and comprehensive tooling.

### Highlights
- Complete brainstorm → plan → build → review → ship orchestration chain
- 29 skills covering the full software development lifecycle
- 7 specialized agent personas for review, testing, security, architecture, and migration
- `/superthink` universal entry point that routes to the right workflow automatically
- `/project-setup` scans codebases and generates lean CLAUDE.md files
- `/audit` checks for plugin conflicts and suggests complementary MCP servers
- Organic growth: agent offers to persist corrections to CLAUDE.md, PostToolUseFailure hook suggests gotchas

### Skills (29)
- **Chain (6):** brainstorming, writing-plans, subagent-driven-development, executing-plans, requesting-code-review, finishing-a-development-branch
- **Domain (10):** test-driven-development, incremental-implementation, api-and-interface-design, frontend-ui-engineering, security-and-hardening, performance-optimization, source-driven-development, code-simplification, documentation-and-adrs, browser-testing-with-devtools
- **Support (8):** systematic-debugging, verification-before-completion, receiving-code-review, using-git-worktrees, dispatching-parallel-agents, context-engineering, writing-skills, wrap-up
- **Build (3):** compound-engineering, threat-modeling, project-setup
- **Meta (2):** using-skills, plugin-audit

### Agents (7)
- code-reviewer, test-engineer, security-auditor, architecture-reviewer, test-generator, dependency-auditor, migration-assistant

### References (6)
- security-checklist, performance-checklist, testing-patterns, accessibility-checklist, supply-chain-security, mcp-integrations

### Commands (12)
- /superthink, /spec, /plan, /build, /test, /review, /simplify, /ship, /debug, /wrapup, /project-setup, /audit

### Hooks (4 types)
- SessionStart: loads meta skill + prompts for project-setup when no CLAUDE.md
- PreToolUse: reminds about finishing-a-development-branch before git push
- SubagentStop: prompts user with completion options after code review
- PostToolUseFailure: suggests CLAUDE.md gotchas when commands fail

---

## Pre-release Development History

### [0.6.0] — 2026-04-14
- MCP integrations reference: guide for 5 recommended MCP servers with install commands
- plugin-audit skill: advisory check for plugin conflicts and complement suggestions
- /audit slash command

### [0.5.0] — 2026-04-14
- compound-engineering skill: multi-stream parallel development with worktree isolation (5 phases)
- threat-modeling skill: proactive STRIDE security methodology (6 steps)
- project-setup skill: scan codebase and generate lean CLAUDE.md (<100 lines) with organic growth
- PostToolUseFailure hook: auto-suggests CLAUDE.md gotchas when commands fail
- SessionStart hook: prompts for project-setup when no CLAUDE.md found

### [0.4.0] — 2026-04-14
- 4 new agent personas: architecture-reviewer, test-generator, dependency-auditor, migration-assistant
- Skills updated to dispatch new agents

### [0.3.0] — 2026-04-14
- Chain last mile: HARD-GATE on review→ship handoff, PreToolUse hook on git push
- Wrap-up skill: lightweight end-of-phase checkpoint
- Backlog & changelog as first-class workflow artifacts under docs/super-agent-skills/
- Chain enforcement: user prompt after code review (A: wrap up, B: ship it, C: keep going)
- SubagentStop + skill-scoped Stop hooks for deterministic post-review prompting

### [0.2.0] — 2026-04-14
- Supply chain security: dependency auditing, license compliance, AI-specific vulnerabilities
- Mid-session context management: degradation signals, tiered memory model, recovery pattern
- Spec-to-test bridge: acceptance test skeleton generation from success criteria
- Selective parallel dispatch: file overlap safety gate, max 3 agents
- Spec-driven test generation: bulk RED phase from acceptance criteria
- Architecture review expansion: 9-bullet axis with Hyrum's Law, coupling analysis
- Self-healing review loop: automated fix-and-re-review up to 3 rounds
- Review sizing gate: hard block on reviews >1000 lines

### [0.1.0] — 2026-04-13
- Initial scaffold: 24 skills merged from superpowers + agent-skills
- 3 agent personas (code-reviewer, test-engineer, security-auditor)
- 4 reference checklists (security, performance, testing, accessibility)
- 9 slash commands including /superthink universal entry point
- Session-start hook for automatic skill routing
- Multi-environment setup docs (Claude Code, Cursor, OpenCode, Gemini, Windsurf, Copilot)

# Changelog

All notable changes to the super-agent-skills plugin.

Format follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- Wrap-up skill: lightweight end-of-phase checkpoint (backlog, changelog, docs, commit, suggest next)
- /wrapup slash command
- Backlog & changelog as first-class workflow artifacts under docs/super-agent-skills/
- Chain enforcement: user prompt after code review (A: wrap up, B: ship it, C: keep going)
- SubagentStop + skill-scoped Stop hooks for deterministic post-review prompting

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

## [1.0.0] — 2026-04-13

### Added
- Initial release: 24 skills (6 chain, 10 domain, 7 support, 1 meta)
- 3 agent personas (code-reviewer, test-engineer, security-auditor)
- 4 reference checklists (security, performance, testing, accessibility)
- 9 slash commands including /superthink universal entry point
- Session-start hook for automatic skill routing
- Multi-environment setup docs (Claude Code, Cursor, OpenCode, Gemini, Windsurf, Copilot)
- Plugin marketplace registration

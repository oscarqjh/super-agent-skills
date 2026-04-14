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

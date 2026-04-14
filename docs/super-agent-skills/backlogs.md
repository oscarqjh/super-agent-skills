# Backlog

## In Progress
(empty)

## Up Next
- [ ] Phase 5: Structural improvements (code health gates, token tracking, feedback loops)

## Ideas (Unprioritized)
- [ ] Shift-right testing skill (now feasible — MCP reference provides install guidance)
- [ ] Observability setup skill (could be a reference doc instead)
- [ ] Phase 6: Documentation (authoring guide, contributing guide, example workflows)
- [ ] Improve natural language trigger robustness for skill routing
- [ ] Investigate content-based PreToolUse matcher (narrow git push hook)
- [ ] Investigate content-based PreToolUse matcher (narrow git push hook to only fire on push commands)

---

## Completed

### Phase 4: MCP Reference + Plugin Audit (2026-04-14)
- [x] MCP integrations reference (5 servers with install commands + skill comparison table)
- [x] plugin-audit skill (4-step conflict/complement check, advisory only)
- [x] /audit slash command

### Phase 3B: Project Setup Skill (2026-04-14)
- [x] project-setup skill (7-step scan, <100 line CLAUDE.md, organic growth)
- [x] SessionStart hook prompts when no CLAUDE.md found
- [x] PostToolUseFailure hook suggests gotchas on command failures
- [x] /project-setup command

### Phase 3A: New Skills — Compound Engineering + Threat Modeling (2026-04-14)
- [x] compound-engineering skill (5-phase multi-stream parallel orchestration)
- [x] threat-modeling skill (STRIDE methodology, 6-step proactive security)
- [x] Routing, brainstorming, writing-plans cross-references updated

### Phase 2: New Agent Personas (2026-04-14)
- [x] architecture-reviewer agent (5-dimension design evaluation)
- [x] test-generator agent (autonomous test suite generation)
- [x] dependency-auditor agent (supply chain audit)
- [x] migration-assistant agent (framework/library migration)
- [x] Skill references: requesting-code-review, TDD, security, using-skills routing

### P0.3: Chain enforcement + wrap-up skill (2026-04-14)
- [x] New wrap-up skill (lightweight checkpoint: backlog, changelog, docs, commit, suggest next)
- [x] Requesting-code-review: user prompt (A: wrap up, B: ship it, C: keep going) replaces forced handoff
- [x] Skill-scoped Stop hook + SubagentStop hook for deterministic prompting
- [x] Updated using-skills routing table and orchestration chain
- [x] /wrapup slash command

### P0.2: Backlog & changelog artifacts (2026-04-14)
- [x] Restructured backlog to flat format (In Progress / Up Next / Ideas / Completed)
- [x] Created changelog.md with Keep a Changelog format
- [x] Brainstorming: backlog integration (add items, capture parallel ideas)
- [x] Finishing-a-development-branch: Step 6 updates backlog + changelog
- [x] Moved all artifacts to docs/super-agent-skills/

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

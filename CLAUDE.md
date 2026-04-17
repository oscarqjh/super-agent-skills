# oscarqjh-super-agent-skills

A Claude Code plugin marketplace. Each plugin lives in `plugins/<name>/`.

## Repo Structure

```
plugins/
  super-agent-skills/     — full-lifecycle engineering skills (brainstorm → ship)
  caveman-agent-skills/   — (planned)
scripts/                  — dev tooling (tests, build scripts)
docs/                     — internal specs, plans, backlogs
output/                   — test output (gitignored)
```

## Plugin: super-agent-skills

Full-lifecycle orchestration (brainstorm → plan → execute → review → ship) with production-grade engineering standards.

### Plugin Directory Structure

All paths below are relative to `plugins/super-agent-skills/`:

- `skills/` — 29 skills organized by role (chain, domain, support, meta)
- `agents/` — 7 subagent personas
- `references/` — 6 reference guides
- `hooks/` — Session-start hook loads meta skill
- `commands/` — 12 slash command shortcuts

### Conventions

- Every skill lives in `plugins/super-agent-skills/skills/<name>/SKILL.md` with YAML frontmatter
- Skill descriptions must be specific enough for Claude to match tasks to skills
- Skills reference each other using `super-agent-skills:<skill-name>` namespace
- Specs are saved to `docs/super-agent-skills/specs/YYYY-MM-DD-<topic>-design.md`
- Plans are saved to `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Skill Phases

- **Define:** brainstorming
- **Plan:** writing-plans
- **Build:** subagent-driven-development, executing-plans, incremental-implementation, test-driven-development, source-driven-development, context-engineering, frontend-ui-engineering, api-and-interface-design, compound-engineering
- **Verify:** systematic-debugging, browser-testing-with-devtools, verification-before-completion, threat-modeling
- **Review:** requesting-code-review, receiving-code-review, code-simplification, security-and-hardening, performance-optimization
- **Ship:** wrap-up, finishing-a-development-branch, documentation-and-adrs

## This Plugin Replaces

- `superpowers` — orchestration and workflow skills
- `agent-skills` — engineering standards and domain skills

Do NOT install either alongside this plugin.

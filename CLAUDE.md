# super-agent-skills

A standalone Claude Code plugin that combines orchestration (brainstorm -> plan -> execute -> review) with production-grade engineering standards (anti-rationalizations, 5-axis review, OWASP, Hyrum's Law).

## How It Works

The user says "I want to build X" and the plugin drives the entire lifecycle automatically via skill-to-skill handoffs:

1. **brainstorming** -> design spec
2. **writing-plans** -> implementation plan
3. **subagent-driven-development** (or executing-plans) -> working code
4. **requesting-code-review** -> verified quality
5. **wrap-up** (checkpoint) or **finishing-a-development-branch** (merge/PR) -> shipped

Domain skills (TDD, security, API design, etc.) auto-trigger during implementation based on context.

## Directory Structure

- `skills/` — 25 skills organized by role (chain, domain, support, meta)
- `agents/` — 3 subagent personas (code-reviewer, test-engineer, security-auditor)
- `references/` — 4 checklists (security, performance, testing, accessibility)
- `hooks/` — Session-start hook loads meta skill
- `commands/` — 10 slash command shortcuts

## Conventions

- Every skill lives in `skills/<name>/SKILL.md` with YAML frontmatter (name, description)
- Skill descriptions must be specific enough for Claude to match tasks to skills
- Skills reference each other using `super-agent-skills:<skill-name>` namespace
- Specs are saved to `docs/super-agent-skills/specs/YYYY-MM-DD-<topic>-design.md`
- Plans are saved to `docs/super-agent-skills/plans/YYYY-MM-DD-<feature-name>.md`

## Skill Phases

- **Define:** brainstorming
- **Plan:** writing-plans
- **Build:** subagent-driven-development, executing-plans, incremental-implementation, test-driven-development, source-driven-development, context-engineering, frontend-ui-engineering, api-and-interface-design
- **Verify:** systematic-debugging, browser-testing-with-devtools, verification-before-completion
- **Review:** requesting-code-review, receiving-code-review, code-simplification, security-and-hardening, performance-optimization
- **Ship:** wrap-up, finishing-a-development-branch, documentation-and-adrs

## This Plugin Replaces

- `superpowers` — orchestration and workflow skills
- `agent-skills` — engineering standards and domain skills

Do NOT install either alongside this plugin.

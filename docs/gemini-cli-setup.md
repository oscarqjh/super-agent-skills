# Using super-agent-skills with Gemini CLI

## Setup

### Option 1: Install as Gemini Skills (Recommended)

Gemini CLI has a native skills system that auto-discovers `SKILL.md` files. Install skills from this repo:

**Install from a local clone:**

```bash
git clone https://github.com/oscarqjh/super-agent-skills.git
gemini skills install /path/to/super-agent-skills/skills/
```

**Install for a specific workspace only:**

```bash
gemini skills install /path/to/super-agent-skills/skills/ --scope workspace
```

Skills installed at workspace scope go into `.gemini/skills/` (or `.agents/skills/`). User-level skills go into `~/.gemini/skills/`.

Once installed, verify with:

```
/skills list
```

Gemini CLI injects skill names and descriptions into the prompt automatically. When it recognizes a matching task, it asks permission to activate the skill before loading its full instructions.

### Option 2: GEMINI.md (Persistent Context)

For skills you want always loaded as persistent project context (rather than on-demand activation), add them to your project's `GEMINI.md`:

```bash
# Create GEMINI.md with core skills as persistent context
cat /path/to/super-agent-skills/skills/test-driven-development/SKILL.md > GEMINI.md
echo -e "\n---\n" >> GEMINI.md
cat /path/to/super-agent-skills/skills/requesting-code-review/SKILL.md >> GEMINI.md
```

You can also modularize by importing from separate files:

```markdown
# Project Instructions

@skills/test-driven-development/SKILL.md
@skills/incremental-implementation/SKILL.md
```

Use `/memory show` to verify loaded context, and `/memory reload` to refresh after changes.

> **Skills vs GEMINI.md:** Skills are on-demand expertise that activate only when relevant, keeping your context window clean. GEMINI.md provides persistent context loaded for every prompt. Use skills for phase-specific workflows and GEMINI.md for always-on project conventions.

## Recommended Configuration

### Always-On (GEMINI.md)

Add these as persistent context for every session:

- `test-driven-development` -- TDD workflow and Prove-It pattern
- `incremental-implementation` -- Build in small verifiable slices

### On-Demand (Skills)

Install these as skills so they activate only when relevant:

- `brainstorming` -- Activates when starting a new project or feature
- `writing-plans` -- Activates when breaking work into tasks
- `requesting-code-review` -- Activates when preparing for merge
- `frontend-ui-engineering` -- Activates when building UI
- `security-and-hardening` -- Activates during security reviews
- `performance-optimization` -- Activates during performance work
- `systematic-debugging` -- Activates when debugging
- `api-and-interface-design` -- Activates when designing APIs

## Driving the Orchestration Chain

In Gemini CLI, the orchestration chain does not auto-handoff between skills. Drive the lifecycle manually:

1. "I want to build X" -> brainstorming skill activates, produces spec
2. "Plan the implementation" -> writing-plans skill activates
3. "Execute the plan" -> implement using incremental-implementation + TDD
4. "Review the code" -> requesting-code-review skill activates
5. "Finish up" -> finishing-a-development-branch skill activates

Each skill tells you what comes next.

## Explicit Context Loading

You can explicitly load any skill into your current session by referencing it:

```markdown
Use the @skills/systematic-debugging/SKILL.md skill to debug this issue.
```

This is useful when you want to ensure a specific workflow is followed without waiting for auto-discovery.

## Using Agents and References

**Agents:** Copy content from the `agents/` directory when requesting specialized review:
- `agents/code-reviewer.md` -- Five-axis code review
- `agents/test-engineer.md` -- Test strategy and coverage
- `agents/security-auditor.md` -- OWASP and threat modeling

**References:** Load checklists from `references/` for detailed patterns:
- `references/security-checklist.md` -- OWASP Top 10, input validation
- `references/performance-checklist.md` -- Core Web Vitals, optimization
- `references/testing-patterns.md` -- AAA pattern, mocking, E2E
- `references/accessibility-checklist.md` -- WCAG 2.1 AA

## Usage Tips

1. **Prefer skills over GEMINI.md** -- Skills activate on demand and keep your context window focused. Only put skills in GEMINI.md if you want them always loaded.
2. **Skill descriptions matter** -- Each SKILL.md has a `description` field in its frontmatter that tells agents when to activate it. The descriptions are optimized for auto-discovery.
3. **Use agents for review** -- Copy `agents/code-reviewer.md` content when requesting structured code reviews.
4. **Combine with references** -- Reference checklists from `references/` when working on specific quality areas like testing or performance.

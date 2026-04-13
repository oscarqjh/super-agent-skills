# Getting Started with super-agent-skills

super-agent-skills works with any AI coding agent that accepts Markdown instructions. This guide covers the universal approach. For tool-specific setup, see the dedicated guides:

- [Claude Code](claude-code-setup.md) (primary, native plugin)
- [Cursor](cursor-setup.md)
- [OpenCode](opencode-setup.md)
- [Gemini CLI](gemini-cli-setup.md)
- [Windsurf](windsurf-setup.md)
- [GitHub Copilot](copilot-setup.md)

## How Skills Work

Each skill is a Markdown file (`SKILL.md`) with YAML frontmatter that describes a specific engineering workflow. When loaded into an agent's context, the agent follows the workflow -- including verification steps, anti-patterns to avoid, and exit criteria.

**Skills are not reference docs.** They are step-by-step processes the agent follows.

### Skill Structure

```
YAML frontmatter (name, description)
  |-- Overview -- What this skill does
  |-- When to Use -- Triggers and conditions
  |-- Core Process -- Step-by-step workflow
  |-- Common Rationalizations -- Excuses and rebuttals
  |-- Red Flags -- Signs the skill is being violated
  +-- Verification -- Exit criteria checklist
```

## Quick Start (Any Agent)

### 1. Clone the repository

```bash
git clone https://github.com/oscarqjh/super-agent-skills.git
```

### 2. Choose a skill

Browse the `skills/` directory. Each subdirectory contains a `SKILL.md` with:
- **When to use** -- triggers that indicate this skill applies
- **Process** -- step-by-step workflow
- **Verification** -- how to confirm the work is done
- **Common rationalizations** -- excuses the agent might use to skip steps
- **Red flags** -- signs the skill is being violated

### 3. Load the skill into your agent

Copy the relevant `SKILL.md` content into your agent's system prompt, rules file, or conversation. The most common approaches:

**System prompt:** Paste the skill content at the start of the session.

**Rules file:** Add skill content to your project's rules file (CLAUDE.md, .cursorrules, AGENTS.md, GEMINI.md, etc.).

**Conversation:** Reference the skill when giving instructions: "Follow the test-driven-development process for this change."

### 4. Use the meta-skill for discovery

Start with the `using-skills` skill loaded. It contains a routing flowchart that maps task types to the appropriate skill.

## The Orchestration Chain

The core innovation of super-agent-skills is the **orchestration chain** -- a sequence of skills that drive a building task from idea to shipped code:

```
brainstorming --> writing-plans --> subagent-driven-development --> requesting-code-review --> finishing-a-development-branch
```

**In Claude Code:** The chain runs automatically. Each skill hands off to the next. You say "build X" and the plugin drives the entire lifecycle.

**In other environments:** You drive the chain manually. After one skill completes, invoke the next one in the sequence. The skills themselves tell you what comes next.

### What Each Chain Skill Does

| Step | Skill | Output |
|------|-------|--------|
| 1. Define | `brainstorming` | Design spec with requirements |
| 2. Plan | `writing-plans` | Implementation plan with dependency graphs |
| 3. Build | `subagent-driven-development` | Working code with tests |
| 4. Review | `requesting-code-review` | 5-axis review (correctness, readability, architecture, security, performance) |
| 5. Ship | `finishing-a-development-branch` | Merged/PR'd code |

## Recommended Setup

### Minimal (Start Here)

Load three essential skills into your rules file:

1. **brainstorming** -- For defining what to build (explores ideas, refines requirements, creates design specs)
2. **test-driven-development** -- For proving code works (red-green-refactor cycle)
3. **requesting-code-review** -- For verifying quality before merge (5-axis review)

These three cover the most critical quality gaps in AI-assisted development.

### Full Lifecycle

For comprehensive coverage, load skills by phase:

```
Starting a project:  brainstorming --> writing-plans
During development:  subagent-driven-development + test-driven-development + incremental-implementation
Before merge:        requesting-code-review + security-and-hardening
Finishing up:        finishing-a-development-branch
```

### Context-Aware Loading

Do not load all 24 skills at once -- it wastes context. Load skills relevant to the current task:

- Working on UI? Load `frontend-ui-engineering`
- Debugging? Load `systematic-debugging`
- Designing an API? Load `api-and-interface-design`
- Refactoring? Load `code-simplification`
- Working with a framework? Load `source-driven-development`
- Performance issue? Load `performance-optimization`

## Using Agents

The `agents/` directory contains pre-configured agent personas for specialized review:

| Agent | Purpose |
|-------|---------|
| `code-reviewer.md` | Senior Staff Engineer -- five-axis code review |
| `test-engineer.md` | QA Specialist -- test strategy, coverage analysis |
| `security-auditor.md` | Security Engineer -- OWASP, threat modeling, hardening |

Load an agent definition when you need specialized review. For example, ask your coding agent to "review this change using the code-reviewer agent persona" and provide the agent definition from `agents/code-reviewer.md`.

## Using References

The `references/` directory contains supplementary checklists that pair with specific skills:

| Reference | Use With |
|-----------|----------|
| `testing-patterns.md` | test-driven-development |
| `performance-checklist.md` | performance-optimization |
| `security-checklist.md` | security-and-hardening |
| `accessibility-checklist.md` | frontend-ui-engineering |

Load a reference when you need detailed patterns beyond what the skill covers.

## Intent -> Skill Quick Reference

| You want to... | Use this skill |
|----------------|---------------|
| Build something new | `brainstorming` (starts the chain) |
| Break work into tasks | `writing-plans` |
| Execute a plan | `subagent-driven-development` |
| Fix a bug | `systematic-debugging` |
| Write tests | `test-driven-development` |
| Review code | `requesting-code-review` |
| Simplify / refactor | `code-simplification` |
| Ship / merge / PR | `finishing-a-development-branch` |
| Design an API | `api-and-interface-design` |
| Build UI | `frontend-ui-engineering` |
| Harden security | `security-and-hardening` |
| Optimize performance | `performance-optimization` |
| Write docs or ADRs | `documentation-and-adrs` |
| Debug in browser | `browser-testing-with-devtools` |
| Run parallel tasks | `dispatching-parallel-agents` |

## Tips

1. **Start with brainstorming** for any non-trivial building work
2. **Always load test-driven-development** when writing code
3. **Do not skip verification steps** -- they are the whole point
4. **Load skills selectively** -- more context is not always better
5. **Use the agents for review** -- different perspectives catch different issues
6. **Follow the chain** -- even manually, the brainstorm-plan-build-review-ship sequence prevents the most common AI development failures

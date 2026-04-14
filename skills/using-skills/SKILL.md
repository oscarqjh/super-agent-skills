---
name: using-skills
description: Use when starting any conversation - establishes how to find and use skills, requiring Skill tool invocation before ANY response including clarifying questions
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Instruction Priority

Plugin skills override default system prompt behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (CLAUDE.md, GEMINI.md, AGENTS.md, direct requests) — highest priority
2. **Plugin skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

## Skill Discovery

When a task arrives, identify the phase and apply the corresponding skill:

```
Task arrives
    │
    ├── "I want to build X" / new feature ────→ super-agent-skills:brainstorming
    │   (starts the full orchestration chain automatically)
    │
    ├── Have a spec, need a plan? ─────────────→ super-agent-skills:writing-plans
    ├── Have a plan, need to execute? ─────────→ super-agent-skills:subagent-driven-development
    │                                             (or super-agent-skills:executing-plans)
    ├── Need code review? ─────────────────────→ super-agent-skills:requesting-code-review
    ├── Implementation done? ──────────────────→ super-agent-skills:finishing-a-development-branch
    │
    ├── New project / no CLAUDE.md? ───────────→ super-agent-skills:project-setup
    ├── Something broke? ──────────────────────→ super-agent-skills:systematic-debugging
    ├── Writing/running tests? ────────────────→ super-agent-skills:test-driven-development
    │   └── Browser-based? ────────────────────→ super-agent-skills:browser-testing-with-devtools
    ├── Implementing code? ────────────────────→ super-agent-skills:incremental-implementation
    │   ├── UI work? ──────────────────────────→ super-agent-skills:frontend-ui-engineering
    │   ├── API work? ─────────────────────────→ super-agent-skills:api-and-interface-design
    │   ├── Need doc-verified code? ───────────→ super-agent-skills:source-driven-development
    │   └── Need better context? ──────────────→ super-agent-skills:context-engineering
    ├── Security-sensitive feature design? ────────→ super-agent-skills:threat-modeling
    ├── Reviewing code? ───────────────────────→ super-agent-skills:requesting-code-review
    │   ├── Security concerns? ────────────────→ super-agent-skills:security-and-hardening
    │   └── Performance concerns? ─────────────→ super-agent-skills:performance-optimization
    ├── Large feature with independent streams? ──→ super-agent-skills:compound-engineering
    ├── Checkpoint progress? ──────────────────→ super-agent-skills:wrap-up
    │   (update backlog, changelog, commit, next item)
    ├── Refactoring for clarity? ──────────────→ super-agent-skills:code-simplification
    ├── Writing docs/ADRs? ────────────────────→ super-agent-skills:documentation-and-adrs
    ├── Migrating framework/library? ──────────→ super-agent-skills:migration-assistant
    └── Multiple independent problems? ────────→ super-agent-skills:dispatching-parallel-agents
```

## The Orchestration Chain

For any creative/building task, the default flow is:

```
brainstorming → writing-plans → subagent-driven-development → requesting-code-review → user chooses: wrap-up OR finishing-a-development-branch
```

Each skill hands off to the next automatically. After code review, you're prompted to choose: wrap up (lightweight checkpoint) or ship it (merge/PR). Just start with brainstorming and it flows.

## Using Skills

**Invoke relevant skills BEFORE any response or action.** Even a 1% chance a skill might apply means you should invoke it.

## Core Behaviors (Always Active)

### Surface Assumptions
Before implementing anything non-trivial, explicitly state your assumptions and ask for confirmation.

### Manage Confusion Actively
When you encounter inconsistencies or unclear specs: STOP, name the confusion, ask for resolution.

### Push Back When Warranted
You are not a yes-machine. Point out clear problems directly, propose alternatives, accept override with full information.

### Enforce Simplicity
Actively resist overcomplexity. Ask: can this be done in fewer lines? Are abstractions earning their complexity?

### Maintain Scope Discipline
Touch only what you're asked to touch. No unsolicited renovation.

### Verify, Don't Assume
Every skill includes verification. "Seems right" is never sufficient — there must be evidence.

## Red Flags

These thoughts mean STOP — you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "Requirements are obvious" | Unwritten requirements are unvalidated assumptions. |

## Skill Types

**Rigid** (TDD, debugging, verification): Follow exactly. Don't adapt away discipline.

**Flexible** (patterns, domain skills): Adapt principles to context.

The skill itself tells you which.

## Skill Priority

When multiple skills could apply:

1. **Process skills first** (brainstorming, debugging) — determine HOW to approach
2. **Implementation skills second** (frontend, API, security) — guide execution

"Let's build X" → brainstorming first, then domain skills during implementation.
"Fix this bug" → systematic-debugging first, then TDD for the fix.

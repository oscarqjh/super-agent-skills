---
name: using-skills
description: "Use when starting any conversation - establishes how to find and use skills, requiring Skill tool invocation before ANY response including clarifying questions"
phase: meta
produces:
  - routing-guidance
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

When a task arrives, identify the phase and find the matching skill:

<!-- BEGIN GENERATED ROUTING TABLE -->
## Skills by Phase

### define
| Skill | Produces | Companions |
|-------|----------|------------|
| brainstorming | design-spec, acceptance-tests | visual-companion (browser-server) |
| threat-modeling | threat-model | — |

### plan
| Skill | Produces | Companions |
|-------|----------|------------|
| writing-plans | implementation-plan | — |

### build
| Skill | Produces | Companions |
|-------|----------|------------|
| api-and-interface-design | api-design, type-contracts | — |
| compound-engineering | multi-stream-code | — |
| context-engineering | optimized-context | — |
| documentation-and-adrs | documentation, adrs | — |
| frontend-ui-engineering | ui-components | — |
| incremental-implementation | working-code | — |
| performance-optimization | optimized-code | — |
| security-and-hardening | hardened-code | — |
| source-driven-development | doc-verified-code | context7 (mcp-server) |
| subagent-driven-development | working-code | — |
| test-driven-development | tested-code | — |

### verify
| Skill | Produces | Companions |
|-------|----------|------------|
| browser-testing-with-devtools | visual-verification, dom-state, console-logs, network-traces | chrome-devtools (mcp-server) |
| systematic-debugging | root-cause-analysis | — |
| verification-before-completion | verification-evidence | — |

### review
| Skill | Produces | Companions |
|-------|----------|------------|
| code-simplification | simplified-code | — |
| receiving-code-review | reviewed-changes | — |
| requesting-code-review | review-report | — |

### ship
| Skill | Produces | Companions |
|-------|----------|------------|
| finishing-a-development-branch | merged-code | — |
| wrap-up | checkpoint | — |

### support
| Skill | Produces | Companions |
|-------|----------|------------|
| dispatching-parallel-agents | parallel-results | — |
| executing-plans | executed-plan | — |
| using-git-worktrees | isolated-workspace | — |
| writing-skills | validated-skill | — |

### meta
| Skill | Produces | Companions |
|-------|----------|------------|
| plugin-audit | audit-report | — |
| project-setup | claude-md | — |
| using-skills | routing-guidance | — |

## Workflow Chains

```
brainstorming → writing-plans → subagent-driven-development → requesting-code-review → [wrap-up | finishing-a-development-branch]
systematic-debugging → test-driven-development → verification-before-completion
compound-engineering → writing-plans (per stream) → subagent-driven-development → requesting-code-review
executing-plans → requesting-code-review → [wrap-up | finishing-a-development-branch]
```

## /superthink Entry Points

| Intent | Routes To |
|--------|----------|
| (see /superthink) | brainstorming |
| (see /superthink) | code-simplification |
| (see /superthink) | context-engineering |
| (see /superthink) | finishing-a-development-branch |
| (see /superthink) | requesting-code-review |
| (see /superthink) | systematic-debugging |
| (see /superthink) | test-driven-development |
| (see /superthink) | writing-plans |

## Auto-Triggers During Implementation

| Context Detected | Invoke |
|-----------------|--------|
| task touches API endpoints | api-and-interface-design |
| task defines module boundaries | api-and-interface-design |
| task creates REST or GraphQL endpoints | api-and-interface-design |
| browser debugging needed | browser-testing-with-devtools |
| visual verification of UI required | browser-testing-with-devtools |
| architecture decision needed | documentation-and-adrs |
| public API change | documentation-and-adrs |
| task modifies UI components | frontend-ui-engineering |
| task creates frontend pages or layouts | frontend-ui-engineering |
| task has performance requirements | performance-optimization |
| performance regression detected | performance-optimization |
| task handles user input or authentication | security-and-hardening |
| task handles external data or integrations | security-and-hardening |
| task uses framework-specific APIs | source-driven-development |


<!-- END GENERATED ROUTING TABLE -->

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

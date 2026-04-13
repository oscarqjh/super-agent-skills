# Using super-agent-skills with Claude Code

Claude Code is the **primary environment** for super-agent-skills. It runs as a native plugin with automatic skill routing, slash commands, session hooks, and skill-to-skill handoffs.

## Installation

### Option 1: From Marketplace (Recommended)

Inside Claude Code, run:

```
/plugin marketplace add oscarqjh/super-agent-skills
/plugin install super-agent-skills@oscarqjh-super-agent-skills
```

### Option 2: Clone and Add Locally

```bash
git clone https://github.com/oscarqjh/super-agent-skills.git
claude plugin add -- ./super-agent-skills
```

Verify installation:

```
/superthink hello
```

If the plugin responds with skill routing, you are set.

## The Universal Entry Point: /superthink

`/superthink` is the only command you need to remember. It understands your intent, gathers project context, and routes to the right workflow automatically.

### Examples

```
/superthink I want to build a task management API
/superthink fix the authentication bug in login.ts
/superthink review my changes before merging
/superthink simplify the auth module
/superthink write tests for the payment service
/superthink plan the database migration
/superthink ship it
```

### How Routing Works

| You say... | Plugin routes to... |
|-----------|-------------------|
| "build X", "create X", "add X", "I want to..." | Full chain: brainstorming -> writing-plans -> subagent-driven-development -> requesting-code-review -> finishing-a-development-branch |
| "fix X", "bug in X", "X is broken", "debug" | systematic-debugging |
| "review", "check my code", "before merging" | requesting-code-review |
| "test", "TDD", "write tests" | test-driven-development |
| "simplify", "refactor", "clean up" | code-simplification |
| "ship", "merge", "PR", "finish" | finishing-a-development-branch |
| "plan", "break down", "task list" | writing-plans |

If intent is ambiguous, the plugin asks one clarifying question before routing.

## The Orchestration Chain

When you build something new, the plugin runs the complete lifecycle automatically with skill-to-skill handoffs:

```
/superthink I want to build X
        |
        v
  1. brainstorming ------------ design spec
        |
        v
  2. writing-plans ------------ implementation plan
        |
        v
  3. subagent-driven-development
     |  Per task:
     |   a. Dispatch implementer (TDD + incremental)
     |   b. Domain skills auto-trigger (API, frontend, security...)
     |   c. Spec compliance review
     |   d. Code quality review (5-axis)
     |  After all tasks: full test suite + self-review
        |
        v
  4. requesting-code-review --- 5-axis review
        |
        v
  5. finishing-a-development-branch --- merge / PR / cleanup
```

You do not need to invoke each skill manually. The chain flows from one to the next.

### Domain Skills That Auto-Trigger

During step 3 (subagent-driven-development), domain skills activate automatically based on what the code touches:

| Domain Skill | Triggers When... |
|-------------|-----------------|
| `test-driven-development` | Implementing any logic or fixing bugs |
| `incremental-implementation` | Task touches multiple files |
| `api-and-interface-design` | Designing APIs, endpoints, module boundaries |
| `frontend-ui-engineering` | Building or modifying UI |
| `security-and-hardening` | Handling user input, auth, external data |
| `performance-optimization` | Performance requirements or regressions |
| `source-driven-development` | Using frameworks or libraries |
| `code-simplification` | Refactoring for clarity |
| `documentation-and-adrs` | Making architectural decisions |
| `browser-testing-with-devtools` | Browser-based debugging |

## Expert Shortcuts

If you know exactly which phase you need, skip the routing with these slash commands:

| Command | Invokes | Use When |
|---------|---------|----------|
| `/spec` | brainstorming | Starting a new feature, exploring ideas |
| `/plan` | writing-plans | Have a spec, need task breakdown |
| `/build` | subagent-driven-development | Have a plan, ready to implement |
| `/test` | test-driven-development | Writing tests, TDD cycle |
| `/review` | requesting-code-review | Code is ready for review |
| `/simplify` | code-simplification | Refactoring existing code |
| `/ship` | finishing-a-development-branch | Ready to merge or create PR |
| `/debug` | systematic-debugging | Something is broken |

Each command accepts optional arguments:

```
/spec a real-time collaborative editor
/plan docs/specs/2026-04-13-editor-design.md
/build docs/plans/2026-04-13-editor.md
/test src/services/payment.ts
/review
/debug the login endpoint returns 500
/simplify src/utils/auth.ts
/ship
```

## Session-Start Hook

Every new Claude Code session automatically loads the `using-skills` meta skill. This skill:

1. Establishes skill discovery rules for the session
2. Ensures the agent checks for applicable skills before every response
3. Provides the intent-to-skill routing flowchart
4. Enforces anti-rationalization (prevents the agent from skipping skills)

You do not need to configure this -- it happens automatically when the plugin is installed.

## Natural Language Triggers

You do not need slash commands at all. Just describe what you want in natural language:

```
"I want to add OAuth support to the API"
  -> brainstorming activates, chain begins

"This function is returning wrong results"
  -> systematic-debugging activates

"Let's clean up the auth module, it's gotten messy"
  -> code-simplification activates

"Are there any security issues in the user input handling?"
  -> security-and-hardening activates
```

The session-start hook ensures the agent always checks for matching skills before responding.

## Using Agents

The plugin includes three specialized subagent personas:

| Agent | Invocation |
|-------|-----------|
| `code-reviewer` | Automatically dispatched by `requesting-code-review` |
| `test-engineer` | Available for test strategy and coverage analysis |
| `security-auditor` | Available for security-focused review |

These are dispatched automatically by the relevant skills. You can also reference them explicitly:

```
"Review this change using the code-reviewer agent"
"Have the security-auditor check the auth module"
"Ask the test-engineer about coverage for payments"
```

## Tips

1. **Start with `/superthink`** -- it handles routing so you do not need to memorize skills
2. **Let the chain run** -- do not interrupt the brainstorm-plan-build-review-ship flow unless you need to
3. **Use expert shortcuts** when you know exactly what phase you need
4. **Trust the anti-rationalization** -- if the plugin insists on brainstorming before coding, it is protecting you from half-baked implementations
5. **Domain skills are automatic** -- you do not need to invoke TDD or security skills; they activate when relevant during implementation

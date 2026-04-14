# Example Workflows

Real examples showing super-agent-skills in action. Each example shows the user's input, what the plugin does at each step, and the output.

## Example 1: Building a REST API

**User:** `/superthink I want to build a task management REST API with CRUD operations`

**What happens:**

```
Step 1: BRAINSTORMING
  Agent explores project context (package.json, existing code)
  Asks: "What database? Auth required? Any existing API patterns?"
  Generates 5 approach variations
  Proposes 2-3 architectures with trade-offs
  Writes design spec -> docs/super-agent-skills/specs/2026-04-14-task-api-design.md
  Generates acceptance test skeletons (Given/When/Then)
  -> You review and approve the spec

Step 2: WRITING PLANS
  Maps dependency graph (schema -> models -> endpoints -> tests)
  Slices vertically (create task, list tasks, update task, delete task)
  Writes bite-sized tasks with exact code and commands
  -> Plan saved to docs/super-agent-skills/plans/

Step 3: SUBAGENT-DRIVEN DEVELOPMENT
  Per task:
    a. Dispatches implementer subagent (follows TDD)
    b. Spec compliance review (did it build what was requested?)
    c. Code quality review (5-axis: correctness, readability, architecture, security, performance)
  Independent tasks dispatched in parallel (max 3)
  After all tasks: full test suite + self-review

Step 4: REQUESTING CODE REVIEW
  Dispatches code-reviewer agent
  If security-sensitive: also dispatches architecture-reviewer
  Self-healing loop: issues found -> auto-fix -> re-review (up to 3 rounds)

Step 5: USER PROMPT
  "Review passed. What would you like to do next?"
  A) Wrap up -- update backlog, changelog, commit
  B) Ship it -- pre-merge checklist, merge/PR
  C) Keep going -- more changes needed
```

**Total time:** depends on complexity, but the user only makes decisions at spec approval and final choice.

---

## Example 2: Fixing a Production Bug

**User:** `/superthink the login endpoint returns 500 after session timeout`

**What happens:**

```
Step 1: SYSTEMATIC DEBUGGING (routed directly, not full chain)
  Phase 1 -- Root Cause: reads error logs, checks auth flow, traces data
  Phase 2 -- Pattern Analysis: finds working vs broken paths
  Phase 3 -- Hypothesis: "session refresh token expired but not handled"
  Phase 4 -- Implementation: writes failing test -> fixes -> verifies
  Phase 5 -- Guard: adds regression test to prevent recurrence

Step 2: USER PROMPT
  "Fix complete. Wrap up or keep going?"
```

**Key:** no brainstorming or planning -- debug workflow goes straight to root cause investigation.

---

## Example 3: Code Review Before Merge

**User:** `/superthink review my changes before merging`

**What happens:**

```
Step 1: REQUESTING CODE REVIEW (routed directly)
  Gets git diff (BASE_SHA..HEAD_SHA)
  Dispatches code-reviewer agent
  5-axis evaluation:
    Correctness: matches spec, edge cases handled
    Architecture: new abstraction not justified (only 1 use case)
    Security: input validated, no secrets
    Performance: no N+1 patterns
    Readability: clear naming, straightforward flow

  Self-healing loop:
    Issue: "abstraction not justified"
    -> Fix agent simplifies to inline code
    -> Re-review: approved

Step 2: USER PROMPT
  "Review passed. Wrap up or ship it?"
```

---

## Example 4: Setting Up a New Project

**User starts Claude Code in a new repo with no CLAUDE.md**

**What happens:**

```
Step 0: SESSION START (automatic)
  Hook detects no CLAUDE.md
  Agent asks: "Would you like me to scan your project and set up a CLAUDE.md?"
  User: "yes"

Step 1: PROJECT SETUP
  Scans package.json -> detects Next.js 15, TypeScript, Tailwind
  Discovers commands: npm run dev, npm test, npm run build
  Detects conventions: functional components, named exports, co-located tests
  Checks for gotchas: monorepo structure, custom webpack config

  Generates CLAUDE.md (78 lines):
    # Project: my-app
    ## Commands
    - Dev: `npm run dev`
    - Test: `npm test -- --watch`
    ## Conventions
    - Named exports only
    - Tests co-located: Button.tsx -> Button.test.tsx
    ## Gotchas
    <!-- Add here when Claude makes wrong assumptions -->

  -> You review and approve

Step 2: PLUGIN AUDIT (optional)
  User: /super-agent-skills:audit
  Checks for conflicts: none
  Complements: context7, typescript-lsp, github
  Suggests: Playwright MCP for UI testing

Step 3: READY TO WORK
  User: /superthink I want to add user authentication
  -> Full chain begins with project context loaded
```

---

## Tips

- **Start with `/superthink`** -- it routes to the right workflow. You don't need to remember which skill to invoke.
- **Let the chain flow** -- don't interrupt with "just commit." The chain handles commits at the right time.
- **Answer the prompts** -- when the agent asks questions during brainstorming, answer them. Better questions = better specs = better code.
- **Use `/wrapup` between tasks** -- it updates the backlog and changelog, keeping your development tracked.

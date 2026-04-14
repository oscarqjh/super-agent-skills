# Phase 1A: Skill Enhancements — Supply Chain Security, Context Management, Spec-to-Test Bridge

## Objective

Enhance 3 existing skills with capabilities identified in the backlog research. These are the simpler, lower-risk enhancements from Phase 1 that add new content sections without changing core skill flow.

**Success criteria:**
- security-and-hardening covers dependency auditing, license compliance, and AI-specific vulnerabilities
- context-engineering guides users through mid-session context degradation and recovery
- brainstorming generates acceptance test skeletons from success criteria before handoff to writing-plans

## Tech Stack

Markdown authoring only. No code, no scripts. Changes are to SKILL.md files and reference documents.

## Files to Modify

| File | Change type | Estimated additions |
|------|------------|-------------------|
| `skills/security-and-hardening/SKILL.md` | Add "Supply Chain Security" subsection + "When to Use" expansion + anti-rationalization entries | ~20 lines |
| `references/security-checklist.md` | Expand "Dependency Security" section | ~30 lines |
| `references/supply-chain-security.md` | NEW file — detailed supply chain security reference | ~120 lines |
| `skills/context-engineering/SKILL.md` | Add "Mid-Session Management" section with degradation signals, compaction, tiered memory, recovery | ~80 lines |
| `skills/brainstorming/SKILL.md` | Add acceptance test skeleton generation step + update checklist and flow | ~35 lines |
| `skills/writing-plans/SKILL.md` | Add note about incorporating acceptance tests from spec | ~5 lines |

---

## Enhancement 1.3: Supply Chain Security

### Changes to security-and-hardening/SKILL.md

**In "When to Use" section, add:**
- Adding or updating dependencies
- Auditing third-party packages for security or license compliance
- Building applications that use LLMs or AI models

**After the existing "OWASP Top 10 Prevention" section (or equivalent last major section), add new section:**

```markdown
## Supply Chain Security

Dependencies are attack surface. Every package you install runs with your application's privileges.

### Before Adding a Dependency

Ask five questions before `npm install`:

1. **Do we need it?** Can the standard library or existing deps solve this?
2. **Is it maintained?** Last commit within 6 months? Active issue responses?
3. **Is it trusted?** Check download count, maintainer count, GitHub stars. Low numbers on a critical package = risk.
4. **Is it safe?** Run `npm audit` / `pip audit` / `cargo audit` before and after adding.
5. **Is the license compatible?** GPL in a proprietary project = legal problem. Check with `license-checker` or equivalent.

### Typosquatting Detection

Before installing, verify the package name exactly:
- `lodash` not `1odash`
- `@babel/core` not `@bable/core`
- Check the npm/PyPI page directly — don't trust autocomplete

### AI-Specific Vulnerabilities

When building applications that use LLMs:
- **Prompt injection:** Treat all user input that reaches an LLM as untrusted. Never concatenate user input directly into system prompts.
- **Output validation:** LLM output is untrusted data. Validate and sanitize before using in SQL, HTML, or system commands.
- **Model supply chain:** Verify model checksums. Don't load models from untrusted sources.

For detailed checklists, see `references/supply-chain-security.md`.
```

**Add to Anti-Rationalizations table:**

| "We trust this package" | Trust is not a security strategy. Audit every dependency — popular packages get compromised too. |
| "It's only a dev dependency" | Dev dependencies execute during build. A compromised build tool owns your CI pipeline. |

### New file: references/supply-chain-security.md

Complete supply chain security reference covering:

**Audit Commands by Ecosystem:**
```
Node.js:   npm audit / npx auditjs
Python:    pip-audit / safety check
Go:        govulncheck ./...
Rust:      cargo audit
Java:      mvn dependency-check:check
```

**License Compatibility Matrix:**
- MIT, Apache-2.0, BSD: permissive, safe for any project
- LGPL: safe if dynamically linked, risky if bundled
- GPL: copyleft — entire project must be GPL if linked
- AGPL: copyleft extends to network use (SaaS)
- Unlicensed: do not use — no permission granted

**Lockfile Hygiene:**
- Always commit lockfiles (package-lock.json, yarn.lock, Pipfile.lock, go.sum)
- Review lockfile diffs in PRs — unexpected changes may indicate tampering
- Use `--frozen-lockfile` / `--ci` in CI to prevent silent resolution changes

**Pre-Install Checklist:**
- [ ] Package name spelled correctly (no typosquatting)
- [ ] Published by expected maintainer
- [ ] Last updated within 12 months
- [ ] No known CVEs (`npm audit` / `pip-audit` clean)
- [ ] License compatible with project
- [ ] Bundle size acceptable (`bundlephobia.com` for JS)
- [ ] No excessive transitive dependencies

**AI-Specific Security Checklist:**
- [ ] User input never directly concatenated into LLM prompts
- [ ] LLM output validated before use in SQL, HTML, shell, or file operations
- [ ] Model files verified by checksum before loading
- [ ] API keys for AI services stored in environment variables, not code
- [ ] Rate limiting on LLM-facing endpoints to prevent abuse
- [ ] Output length limits to prevent resource exhaustion

### Changes to references/security-checklist.md

Expand "Dependency Security" section from the current brief list to include:
- [ ] `npm audit` / `pip-audit` / `cargo audit` shows no critical or high vulnerabilities
- [ ] All dependencies have compatible licenses (no GPL in proprietary projects)
- [ ] Lockfile committed and reviewed in PRs
- [ ] No unused dependencies (`npx depcheck` / `pip-extra-reqs`)
- [ ] Package names verified (no typosquatting)
- [ ] Dev dependencies reviewed (they execute during build)
- [ ] No packages with known supply chain incidents

---

## Enhancement 1.4: Mid-Session Context Management

### Changes to context-engineering/SKILL.md

**After the existing "Level 5: Conversation Management" section, add:**

```markdown
## Mid-Session Context Management

Context degrades over long sessions. Recognize it, manage it, or recover from it.

### Degradation Signals

Watch for these signs that the agent is losing useful context:

| Signal | Meaning |
|--------|---------|
| Agent references APIs or imports that don't exist | Hallucinating — real context pushed out by stale history |
| Agent re-implements a utility that already exists in the codebase | Forgot earlier file reads |
| Agent ignores conventions it followed earlier | Rules file content compacted away |
| Agent asks questions you already answered | Conversation history lost to compaction |
| Agent's code quality drops noticeably | Context overload — too much low-value information |

### When to Compact

Compact **before** critical work, not during:

- Before starting a new task in a multi-task session
- When you notice any degradation signal above
- After a long debugging session (stale error traces fill context)
- Before the final review/verification pass

### What to Preserve vs Discard

**Preserve (high value per token):**
- Current task description and acceptance criteria
- Key decisions made in this session (and why)
- File paths being modified
- Active error messages or test failures
- Rules file content (conventions, commands)

**Discard (low value per token):**
- Exploration history (files read but not modified)
- Rejected approaches and their reasoning
- Resolved error traces from earlier in the session
- Verbose tool output from successful operations

### Tiered Memory Model

Organize what's loaded into context by temperature:

```
HOT (~2000 tokens) — always in context:
  Current task spec/acceptance criteria
  Files being actively modified
  Active errors or test failures

WARM (~3000 tokens) — loaded on demand:
  Related test files
  Type definitions and interfaces
  One example of the pattern to follow

COLD (not in context) — load only when needed:
  Full project spec
  Architecture docs
  Reference checklists
  Historical decisions
```

**Rule of thumb:** If you haven't referenced it in the last 3 turns, it should be warm or cold, not hot.

### Cross-Session Persistence

Know where to save different types of knowledge:

| What | Where | Why |
|------|-------|-----|
| Project conventions, tech stack, commands | CLAUDE.md | Loaded every session automatically |
| Feature requirements, success criteria | `docs/specs/*.md` | Loaded when working on that feature |
| Architectural decisions and rationale | ADRs in `docs/` | Loaded when revisiting that area |
| User preferences, workflow patterns | Memory files | Recalled by agent as needed |
| Current task progress | Conversation context | Lost on session end — summarize before closing |

**Before ending a session with incomplete work**, write a handoff note:

```
SESSION HANDOFF:
- Working on: [feature/task]
- Completed: [what's done]
- Next step: [what to do next]
- Key decision: [any decision that's not obvious from code]
- Files involved: [list]
```

Save this as a comment in the relevant spec/plan file or as a commit message.

### Recovery Pattern

When context is degraded beyond saving (agent consistently hallucinating or ignoring conventions):

1. **Don't fight it.** Start a new session.
2. **Write the handoff note** (see above)
3. **In the new session, load:**
   - The handoff note
   - The relevant spec section
   - The files being modified
4. **Verify the agent is oriented:** Ask it to summarize what it understands before continuing work.
```

---

## Enhancement 1.6: Spec-to-Test Bridge

### Changes to brainstorming/SKILL.md

**In the Checklist section, add new item between 7 (Spec self-review) and 8 (User reviews written spec):**

```markdown
8. **Generate acceptance test skeletons** — extract success criteria from the spec and write test outlines (see below)
```

(Renumber subsequent items: old 8 becomes 9, old 9 becomes 10)

**After the "Spec Self-Review" section, before "User Review Gate", add:**

```markdown
**Acceptance Test Generation:**

After the spec self-review passes, extract each success criterion and generate a test skeleton. Append these to the spec document as a new section:

```markdown
## Acceptance Tests

Generated from success criteria. These will be incorporated into the implementation plan as pre-defined test cases.

- [ ] `test: [success criterion rephrased as test name]`
      Given: [precondition]
      When: [action]
      Then: [expected outcome]

- [ ] `test: [next criterion]`
      Given: [precondition]
      When: [action]
      Then: [expected outcome]
```

**Rules for test skeletons:**
- One test per success criterion — no more, no less
- Use Given/When/Then format (readable by anyone, framework-agnostic)
- Be specific about inputs and expected outputs (not "should work correctly")
- Include at least one negative test (what should NOT happen)
- These are skeletons, not implementations — the implementer writes the actual test code during TDD

This bridges the gap between "what we want" (spec) and "how we prove it works" (tests). The implementer doesn't invent test cases from scratch — they implement pre-defined acceptance criteria.
```

**Update the Process Flow diagram** to include the new step between "Spec self-review" and "User reviews spec":

Add node: `"Generate acceptance\ntest skeletons"` between self-review and user review.

### Changes to writing-plans/SKILL.md

**In the "Plan Document Header" section, add a note:**

```markdown
**If the spec includes an "Acceptance Tests" section** (generated during brainstorming), incorporate those test skeletons into the plan's task steps. Each acceptance test should map to a specific task's test step — don't make the implementer re-derive tests that already exist in the spec.
```

---

## Boundaries

- **Always:** Keep new content consistent with existing skill voice and structure
- **Always:** Reference supporting files rather than inlining large checklists (keeps SKILL.md under 500 lines)
- **Never:** Change existing behavior — all changes are additive
- **Never:** Remove or weaken existing security guidance when adding supply chain content
- **Ask first:** If any skill exceeds 500 lines after additions, consider extracting to a supporting file

## Testing Strategy

Since this is markdown authoring, "testing" means verification:

- [ ] Each modified SKILL.md has valid YAML frontmatter after changes
- [ ] No broken internal references (skill names, file paths)
- [ ] New sections follow the existing structure pattern (heading level, tone, format)
- [ ] supply-chain-security.md referenced correctly from security-and-hardening SKILL.md
- [ ] Acceptance test generation step appears in brainstorming checklist at the right position
- [ ] writing-plans references acceptance tests from spec
- [ ] All skill cross-references use `super-agent-skills:` namespace

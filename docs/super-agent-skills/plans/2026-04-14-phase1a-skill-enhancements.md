# Phase 1A Skill Enhancements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use super-agent-skills:subagent-driven-development (recommended) or super-agent-skills:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enhance 3 existing skills with supply chain security, mid-session context management, and spec-to-test bridge capabilities.

**Architecture:** Additive changes only — new sections appended to existing SKILL.md files, one new reference file created. No existing behavior modified.

**Tech Stack:** Markdown authoring. No code or scripts.

---

## Source Paths

```
PLUGIN = /mnt/umm/users/qianjianheng/workspace/super-agent-skills
SPEC   = docs/specs/2026-04-14-phase1a-skill-enhancements-design.md
```

---

### Task 1: Create supply-chain-security reference file

**Files:**
- Create: `references/supply-chain-security.md`

- [ ] **Step 1: Create the reference file**

Write `references/supply-chain-security.md` with the following complete content:

```markdown
# Supply Chain Security Reference

Quick reference for dependency auditing, license compliance, and AI-specific security. Use alongside the `super-agent-skills:security-and-hardening` skill.

## Audit Commands by Ecosystem

| Ecosystem | Audit Command | Alternative |
|-----------|--------------|-------------|
| Node.js | `npm audit` | `npx auditjs` |
| Python | `pip-audit` | `safety check` |
| Go | `govulncheck ./...` | `nancy` |
| Rust | `cargo audit` | — |
| Java | `mvn dependency-check:check` | `gradle dependencyCheckAnalyze` |
| Ruby | `bundle audit` | — |
| PHP | `composer audit` | — |

## License Compatibility Matrix

| License | Type | Safe for proprietary? | Notes |
|---------|------|----------------------|-------|
| MIT | Permissive | Yes | No restrictions |
| Apache-2.0 | Permissive | Yes | Must include license/notice |
| BSD-2/3 | Permissive | Yes | Must include copyright |
| ISC | Permissive | Yes | Simplified MIT |
| LGPL | Weak copyleft | Yes (if dynamically linked) | Risky if statically linked or bundled |
| MPL-2.0 | Weak copyleft | Yes (file-level) | Modified files must stay MPL |
| GPL-2.0/3.0 | Strong copyleft | No | Entire project must be GPL |
| AGPL-3.0 | Network copyleft | No | Extends to SaaS/network use |
| Unlicensed | None | No | No permission granted — do not use |

**When in doubt:** Check with legal. License violations have real consequences.

## Lockfile Hygiene

- **Always commit lockfiles**: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Pipfile.lock`, `go.sum`, `Cargo.lock`
- **Review lockfile diffs in PRs**: unexpected changes may indicate dependency confusion or tampering
- **Use frozen installs in CI**: `npm ci`, `yarn --frozen-lockfile`, `pip install --require-hashes`
- **Regenerate periodically**: run `npm update` / `pip-compile --upgrade` on a schedule to pick up patches

## Pre-Install Checklist

Before adding any dependency:

- [ ] Package name spelled correctly (no typosquatting: `lodash` not `1odash`)
- [ ] Published by expected maintainer (check npm/PyPI page)
- [ ] Last updated within 12 months
- [ ] No known CVEs (`npm audit` / `pip-audit` clean after adding)
- [ ] License compatible with project (see matrix above)
- [ ] Bundle size acceptable (check `bundlephobia.com` for JS packages)
- [ ] No excessive transitive dependencies (check `npm ls --all` depth)
- [ ] README and docs exist (abandoned packages often lack these)

## Typosquatting Detection

Common patterns to watch for:
- Letter swaps: `lodash` vs `1odash`, `@babel/core` vs `@bable/core`
- Scope hijacking: `@company/util` vs `@c0mpany/util`
- Extra/missing hyphens: `react-dom` vs `reactdom` vs `react--dom`
- Similar names: `colors` vs `colour` vs `colores`

**Always verify on the official registry page before installing.**

## AI-Specific Security Checklist

When building applications that use LLMs or AI models:

### Prompt Security
- [ ] User input never directly concatenated into system prompts
- [ ] Prompt templates use parameterized injection points (not string concatenation)
- [ ] System prompts are not exposed to end users
- [ ] Prompt injection testing is part of the test suite

### Output Validation
- [ ] LLM output validated before use in SQL queries
- [ ] LLM output sanitized before rendering as HTML (prevent XSS)
- [ ] LLM output not passed to shell commands without sanitization
- [ ] LLM output not used as file paths without validation
- [ ] Output length limits prevent resource exhaustion

### Model Supply Chain
- [ ] Model files verified by checksum before loading
- [ ] Models downloaded from trusted sources only (official registries)
- [ ] No execution of code embedded in model files
- [ ] API keys for AI services stored in environment variables, not code

### Rate Limiting
- [ ] Rate limiting on LLM-facing endpoints to prevent abuse
- [ ] Cost monitoring and alerts for API-based LLM usage
- [ ] Token limits per request to prevent context window stuffing

## Common Supply Chain Attacks

| Attack | How it works | Prevention |
|--------|-------------|-----------|
| Typosquatting | Malicious package with similar name | Verify exact name on registry |
| Dependency confusion | Public package shadows private one | Use scoped packages, configure registries |
| Maintainer takeover | Attacker gains publish access | Pin versions, review lockfile diffs |
| Build script injection | Malicious postinstall script | Use `--ignore-scripts`, review scripts |
| Star jacking | Fake popularity metrics | Check actual download numbers, not just stars |
```

- [ ] **Step 2: Verify file created**

```bash
wc -l references/supply-chain-security.md
head -3 references/supply-chain-security.md
```

Expected: ~100-120 lines, starts with `# Supply Chain Security Reference`.

- [ ] **Step 3: Commit**

```bash
git add references/supply-chain-security.md
git commit -m "feat: add supply chain security reference checklist"
```

---

### Task 2: Enhance security-and-hardening skill with supply chain section

**Files:**
- Modify: `skills/security-and-hardening/SKILL.md`

- [ ] **Step 1: Read the current file**

Read `skills/security-and-hardening/SKILL.md` to find:
1. The "When to Use" section (add 3 new trigger items)
2. The last major section before "Common Rationalizations" (insert new section after it)
3. The "Common Rationalizations" table (add 2 new entries)

- [ ] **Step 2: Add to "When to Use" section**

After the existing list items in "When to Use", add:

```markdown
- Adding or updating third-party dependencies
- Auditing packages for security or license compliance
- Building applications that use LLMs or AI models
```

- [ ] **Step 3: Add "Supply Chain Security" section**

Before the "Common Rationalizations" section, add this new section:

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

- [ ] **Step 4: Add anti-rationalization entries**

In the "Common Rationalizations" table, add two new rows:

```markdown
| "We trust this package" | Trust is not a security strategy. Audit every dependency — popular packages get compromised too. |
| "It's only a dev dependency" | Dev dependencies execute during build. A compromised build tool owns your CI pipeline. |
```

- [ ] **Step 5: Verify no stale references**

```bash
grep "superpowers:" skills/security-and-hardening/SKILL.md || echo "Clean"
grep "supply-chain-security.md" skills/security-and-hardening/SKILL.md
```

Expected: "Clean" (no stale refs), and the reference to supply-chain-security.md is present.

- [ ] **Step 6: Commit**

```bash
git add skills/security-and-hardening/SKILL.md
git commit -m "feat: add supply chain security to security-and-hardening skill"
```

---

### Task 3: Expand dependency security section in security-checklist.md

**Files:**
- Modify: `references/security-checklist.md`

- [ ] **Step 1: Read the current "Dependency Security" section**

Read `references/security-checklist.md` and find the "Dependency Security" section.

- [ ] **Step 2: Replace the dependency security section**

Replace the existing "Dependency Security" section with this expanded version:

```markdown
## Dependency Security

- [ ] `npm audit` / `pip-audit` / `cargo audit` shows no critical or high vulnerabilities
- [ ] All dependencies have compatible licenses (no GPL in proprietary projects without legal review)
- [ ] Lockfile committed and reviewed in PRs
- [ ] `--frozen-lockfile` / `npm ci` used in CI (no silent resolution changes)
- [ ] No unused dependencies (`npx depcheck` / `pip-extra-reqs`)
- [ ] Package names verified against official registry (no typosquatting)
- [ ] Dev dependencies reviewed (they execute during build — compromised build tool = compromised pipeline)
- [ ] No packages with known supply chain incidents
- [ ] New dependencies reviewed before merging: maintainer, age, download count, bundle size

For detailed supply chain security guidance, see `references/supply-chain-security.md`.
```

- [ ] **Step 3: Verify**

```bash
grep "supply-chain-security.md" references/security-checklist.md
grep -c "\- \[ \]" references/security-checklist.md
```

Expected: reference exists, checklist item count increased from original.

- [ ] **Step 4: Commit**

```bash
git add references/security-checklist.md
git commit -m "feat: expand dependency security section in security checklist"
```

---

### Checkpoint: After Tasks 1-3 (Supply Chain Security)

- [ ] `references/supply-chain-security.md` exists with audit commands, license matrix, AI-specific checklist
- [ ] `skills/security-and-hardening/SKILL.md` has "Supply Chain Security" section and updated "When to Use"
- [ ] `references/security-checklist.md` has expanded dependency security section
- [ ] Both reference files cross-reference each other
- [ ] No stale `superpowers:` references in any modified file

---

### Task 4: Enhance context-engineering with mid-session management

**Files:**
- Modify: `skills/context-engineering/SKILL.md`

- [ ] **Step 1: Read the current file**

Read `skills/context-engineering/SKILL.md` to find the "Level 5: Conversation Management" section. The new content goes after this section (and before "Context Packing Strategies" or equivalent).

- [ ] **Step 2: Add "Mid-Session Context Management" section**

After "Level 5: Conversation Management" (which currently has brief guidance about starting fresh sessions and summarizing progress), add this new section:

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

- [ ] **Step 3: Verify file integrity**

```bash
head -4 skills/context-engineering/SKILL.md
grep "Mid-Session Context Management" skills/context-engineering/SKILL.md
grep "Degradation Signals" skills/context-engineering/SKILL.md
grep "Tiered Memory Model" skills/context-engineering/SKILL.md
grep "Recovery Pattern" skills/context-engineering/SKILL.md
wc -l skills/context-engineering/SKILL.md
```

Expected: all grep matches found, file ~370 lines (289 original + ~80 new).

- [ ] **Step 4: Commit**

```bash
git add skills/context-engineering/SKILL.md
git commit -m "feat: add mid-session context management to context-engineering skill"
```

---

### Checkpoint: After Task 4 (Context Management)

- [ ] `skills/context-engineering/SKILL.md` has "Mid-Session Context Management" section
- [ ] Section includes: Degradation Signals, When to Compact, Preserve vs Discard, Tiered Memory, Cross-Session Persistence, Recovery Pattern
- [ ] File under 500 lines
- [ ] No stale references

---

### Task 5: Add spec-to-test bridge to brainstorming skill

**Files:**
- Modify: `skills/brainstorming/SKILL.md`

- [ ] **Step 1: Read the current file**

Read `skills/brainstorming/SKILL.md` to find:
1. The Checklist section (items 1-9)
2. The "Spec Self-Review" section
3. The "User Review Gate" section
4. The Process Flow graphviz diagram

- [ ] **Step 2: Update the Checklist**

In the Checklist section, add a new item 8 and renumber:

Current items 1-7 stay the same. Then:

```markdown
8. **Generate acceptance test skeletons** — extract success criteria from the spec and write test outlines (see below)
9. **User reviews written spec** — ask user to review the spec file before proceeding
10. **Transition to implementation** — invoke writing-plans skill to create implementation plan
```

(Old items 8 and 9 become 9 and 10)

- [ ] **Step 3: Add "Acceptance Test Generation" section**

After the "Spec Self-Review" section and before the "User Review Gate" section, add:

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

- [ ] **Step 4: Update the Process Flow diagram**

In the graphviz `digraph brainstorming`, add the new node and edges:

Add this node:
```
"Generate acceptance\ntest skeletons" [shape=box];
```

Change the edge from self-review to user review. Replace:
```
"Spec self-review\n(fix inline)" -> "User reviews spec?";
```

With:
```
"Spec self-review\n(fix inline)" -> "Generate acceptance\ntest skeletons";
"Generate acceptance\ntest skeletons" -> "User reviews spec?";
```

- [ ] **Step 5: Verify**

```bash
grep "acceptance test skeletons" skills/brainstorming/SKILL.md
grep "Given/When/Then" skills/brainstorming/SKILL.md
grep -c "Generate acceptance" skills/brainstorming/SKILL.md
wc -l skills/brainstorming/SKILL.md
```

Expected: matches found, file ~270 lines (237 + ~35 new).

- [ ] **Step 6: Commit**

```bash
git add skills/brainstorming/SKILL.md
git commit -m "feat: add acceptance test skeleton generation to brainstorming skill"
```

---

### Task 6: Add acceptance test reference to writing-plans skill

**Files:**
- Modify: `skills/writing-plans/SKILL.md`

- [ ] **Step 1: Read the "Plan Document Header" section**

Read `skills/writing-plans/SKILL.md` and find the "Plan Document Header" section (contains the header template with Goal, Architecture, Tech Stack).

- [ ] **Step 2: Add acceptance test note**

After the Plan Document Header template (after the closing ` ``` `), add:

```markdown
**If the spec includes an "Acceptance Tests" section** (generated during brainstorming), incorporate those test skeletons into the plan's task steps. Each acceptance test should map to a specific task's test step — don't make the implementer re-derive tests that already exist in the spec.
```

- [ ] **Step 3: Verify**

```bash
grep "Acceptance Tests" skills/writing-plans/SKILL.md
wc -l skills/writing-plans/SKILL.md
```

Expected: match found, file ~225 lines (219 + ~5 new).

- [ ] **Step 4: Commit**

```bash
git add skills/writing-plans/SKILL.md
git commit -m "feat: add acceptance test incorporation note to writing-plans skill"
```

---

### Checkpoint: After Tasks 5-6 (Spec-to-Test Bridge)

- [ ] `skills/brainstorming/SKILL.md` has acceptance test generation step in checklist (item 8)
- [ ] Brainstorming process flow diagram includes the new node
- [ ] `skills/writing-plans/SKILL.md` references acceptance tests from spec
- [ ] No stale references in any modified file

---

### Task 7: Final integration verification

**Files:**
- Verify: all files modified in Tasks 1-6

- [ ] **Step 1: Verify no stale references across all modified files**

```bash
for f in skills/security-and-hardening/SKILL.md references/security-checklist.md references/supply-chain-security.md skills/context-engineering/SKILL.md skills/brainstorming/SKILL.md skills/writing-plans/SKILL.md; do
  echo "=== $f ==="
  grep "superpowers:" "$f" || echo "Clean"
done
```

Expected: all "Clean".

- [ ] **Step 2: Verify all new cross-references resolve**

```bash
# supply-chain-security.md referenced from security skill
grep "supply-chain-security.md" skills/security-and-hardening/SKILL.md

# supply-chain-security.md referenced from security checklist
grep "supply-chain-security.md" references/security-checklist.md

# acceptance tests referenced in writing-plans
grep "Acceptance Tests" skills/writing-plans/SKILL.md
```

All 3 must show matches.

- [ ] **Step 3: Verify YAML frontmatter intact on all modified skills**

```bash
for skill in security-and-hardening context-engineering brainstorming writing-plans; do
  echo "=== $skill ==="
  head -4 "skills/$skill/SKILL.md"
done
```

Expected: all have `---`, `name:`, `description:`, `---` frontmatter.

- [ ] **Step 4: Verify file sizes are reasonable**

```bash
for f in skills/security-and-hardening/SKILL.md skills/context-engineering/SKILL.md skills/brainstorming/SKILL.md skills/writing-plans/SKILL.md references/supply-chain-security.md references/security-checklist.md; do
  echo "$(wc -l < "$f") $f"
done
```

Expected: no file over 500 lines.

---

## Summary

| Task | Enhancement | Files | Estimated lines added |
|------|------------|-------|----------------------|
| 1 | Supply chain security reference | Create: `references/supply-chain-security.md` | ~120 |
| 2 | Security skill enhancement | Modify: `skills/security-and-hardening/SKILL.md` | ~25 |
| 3 | Security checklist expansion | Modify: `references/security-checklist.md` | ~15 |
| 4 | Context management enhancement | Modify: `skills/context-engineering/SKILL.md` | ~80 |
| 5 | Spec-to-test bridge | Modify: `skills/brainstorming/SKILL.md` | ~35 |
| 6 | Writing-plans acceptance test note | Modify: `skills/writing-plans/SKILL.md` | ~5 |
| 7 | Integration verification | Verify all | 0 |

**Total: 7 tasks, 1 new file, 4 modified skills, 1 modified reference, ~280 lines added**

# Using super-agent-skills with Cursor

## Setup

### Option 1: Rules Directory (Recommended)

Cursor supports a `.cursor/rules/` directory for project-specific rules:

```bash
# Clone the repo
git clone https://github.com/oscarqjh/super-agent-skills.git

# Create the rules directory in your project
mkdir -p .cursor/rules

# Copy essential skills as rules
cp /path/to/super-agent-skills/skills/test-driven-development/SKILL.md .cursor/rules/test-driven-development.md
cp /path/to/super-agent-skills/skills/requesting-code-review/SKILL.md .cursor/rules/requesting-code-review.md
cp /path/to/super-agent-skills/skills/incremental-implementation/SKILL.md .cursor/rules/incremental-implementation.md
```

Rules in this directory are automatically loaded into Cursor's context.

### Option 2: .cursorrules File

Create a `.cursorrules` file in your project root with the essential skills inlined:

```bash
# Generate a combined rules file
cat /path/to/super-agent-skills/skills/test-driven-development/SKILL.md > .cursorrules
echo "\n---\n" >> .cursorrules
cat /path/to/super-agent-skills/skills/requesting-code-review/SKILL.md >> .cursorrules
echo "\n---\n" >> .cursorrules
cat /path/to/super-agent-skills/skills/incremental-implementation/SKILL.md >> .cursorrules
```

### Option 3: Notepads

Cursor's Notepads feature lets you store reusable context. Create a notepad for each skill you use frequently:

1. Open Cursor -> Settings -> Notepads
2. Create a new notepad named "swe: Brainstorming"
3. Paste the content of `skills/brainstorming/SKILL.md`
4. Reference it in chat with `@notepad swe: Brainstorming`

Repeat for other skills you want on-demand access to.

## Recommended Configuration

### Essential Skills (Always Load via .cursor/rules/)

Add these three to `.cursor/rules/`:

1. `test-driven-development.md` -- TDD workflow and Prove-It pattern
2. `requesting-code-review.md` -- Five-axis code review
3. `incremental-implementation.md` -- Build in small verifiable slices

### Phase-Specific Skills (Load as Notepads)

Create notepads for skills you use contextually:

- "swe: Brainstorming" -> `brainstorming/SKILL.md`
- "swe: Writing Plans" -> `writing-plans/SKILL.md`
- "swe: Frontend UI" -> `frontend-ui-engineering/SKILL.md`
- "swe: Security" -> `security-and-hardening/SKILL.md`
- "swe: Performance" -> `performance-optimization/SKILL.md`
- "swe: Debugging" -> `systematic-debugging/SKILL.md`
- "swe: API Design" -> `api-and-interface-design/SKILL.md`
- "swe: Code Simplification" -> `code-simplification/SKILL.md`

Reference them with `@notepad` when working on relevant tasks.

## Driving the Orchestration Chain Manually

In Cursor, the orchestration chain does not run automatically. You drive it manually by invoking skills in sequence:

1. Start with `@notepad swe: Brainstorming` -- get a design spec
2. Then `@notepad swe: Writing Plans` -- break spec into tasks
3. Implement each task following the always-loaded rules (TDD + incremental)
4. When done, tell Cursor: "Review this using the requesting-code-review rules"
5. Finally, commit/merge following your project's workflow

Each skill tells you what comes next in the chain, so you always know the next step.

## Using Agents for Review

Copy agent definitions from `agents/` and tell Cursor to adopt the persona:

```
"Review this diff using this code review framework:"
[paste agents/code-reviewer.md content]
```

Available agents:
- `agents/code-reviewer.md` -- Five-axis review
- `agents/test-engineer.md` -- Test strategy and coverage
- `agents/security-auditor.md` -- OWASP and threat modeling

## Using References

Paste reference checklists into the chat when working on specific quality areas:

- `references/security-checklist.md` -- When building auth, user input handling
- `references/performance-checklist.md` -- When optimizing performance
- `references/testing-patterns.md` -- When designing test suites
- `references/accessibility-checklist.md` -- When building UI

## Usage Tips

1. **Do not load all skills at once** -- Cursor has context limits. Load 2-3 skills as rules and keep others as notepads.
2. **Reference skills explicitly** -- Tell Cursor "Follow the test-driven-development rules for this change" to ensure it reads the loaded rules.
3. **Use notepads for the chain** -- The brainstorming and writing-plans skills work well as notepads since you only need them at the start of a feature.
4. **Load references on demand** -- When working on performance, reference `@notepad performance-checklist` or paste the checklist content directly.

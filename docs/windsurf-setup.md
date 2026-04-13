# Using super-agent-skills with Windsurf

## Setup

### Project Rules

Windsurf uses `.windsurfrules` for project-specific agent instructions:

```bash
# Clone the repo
git clone https://github.com/oscarqjh/super-agent-skills.git

# Create a combined rules file from your most important skills
cat /path/to/super-agent-skills/skills/test-driven-development/SKILL.md > .windsurfrules
echo "\n---\n" >> .windsurfrules
cat /path/to/super-agent-skills/skills/incremental-implementation/SKILL.md >> .windsurfrules
echo "\n---\n" >> .windsurfrules
cat /path/to/super-agent-skills/skills/requesting-code-review/SKILL.md >> .windsurfrules
```

### Global Rules

For skills you want across all projects, add them to Windsurf's global rules:

1. Open Windsurf -> Settings -> AI -> Global Rules
2. Paste the content of your most-used skills

## Recommended Configuration

Keep `.windsurfrules` focused on 2-3 essential skills to stay within context limits:

```
# .windsurfrules
# Essential super-agent-skills for this project

[Paste test-driven-development SKILL.md]

---

[Paste incremental-implementation SKILL.md]

---

[Paste requesting-code-review SKILL.md]
```

These three cover the core quality loop: build incrementally, test first, review before merge.

### Adding More Skills

When working on specific tasks, paste additional skill content into the chat:

- Starting a feature -> paste `brainstorming/SKILL.md`
- Planning work -> paste `writing-plans/SKILL.md`
- Debugging -> paste `systematic-debugging/SKILL.md`
- Building UI -> paste `frontend-ui-engineering/SKILL.md`
- Security work -> paste `security-and-hardening/SKILL.md`
- API design -> paste `api-and-interface-design/SKILL.md`

## Driving the Orchestration Chain

In Windsurf, the orchestration chain does not run automatically. Drive it manually:

1. Paste `brainstorming/SKILL.md` and describe what you want to build
2. Once you have a spec, paste `writing-plans/SKILL.md` and ask for a task breakdown
3. Implement tasks following the always-loaded rules (TDD + incremental)
4. When done, tell Windsurf: "Review this using the requesting-code-review rules"
5. Commit and merge following your project's workflow

## Using Agents and References

**Agents:** Paste agent definitions into the chat for specialized review:
- `agents/code-reviewer.md` -- Five-axis code review
- `agents/test-engineer.md` -- Test strategy and coverage
- `agents/security-auditor.md` -- OWASP and threat modeling

**References:** Paste checklists and ask Windsurf to verify each item:
- `references/security-checklist.md`
- `references/performance-checklist.md`
- `references/testing-patterns.md`
- `references/accessibility-checklist.md`

## Usage Tips

1. **Be selective** -- Windsurf's context is limited. Choose 2-3 skills that address your biggest quality gaps and load them in `.windsurfrules`.
2. **Reference in conversation** -- Paste additional skill content into the chat when working on specific phases (e.g., paste `security-and-hardening` when building auth).
3. **Use references as checklists** -- Paste `references/security-checklist.md` and ask Windsurf to verify each item against your code.
4. **Name skills in prompts** -- Tell Windsurf "Follow the test-driven-development rules" to ensure it applies the loaded workflow.

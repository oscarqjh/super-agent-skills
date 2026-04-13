# Using super-agent-skills with GitHub Copilot

## Setup

### Copilot Skills Directory

Copilot supports agent skills using a `.github/skills`, `.claude/skills`, or `.agents/skills` directory in your repository:

```bash
# Clone the repo
git clone https://github.com/oscarqjh/super-agent-skills.git

# Create skills directory in your project
mkdir -p .github/skills

# Copy essential skills
cp -r /path/to/super-agent-skills/skills/test-driven-development .github/skills/
cp -r /path/to/super-agent-skills/skills/requesting-code-review .github/skills/
cp -r /path/to/super-agent-skills/skills/incremental-implementation .github/skills/
```

For more details, refer to [Creating agent skills for GitHub Copilot](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-skills).

### Project-Level Instructions

GitHub Copilot supports project-level instructions via `.github/copilot-instructions.md`. Create one with summarized skill rules:

```markdown
# Project Coding Standards

## Testing
- Write tests before code (TDD)
- For bugs: write a failing test first, then fix (Prove-It pattern)
- Test hierarchy: unit > integration > e2e (use the lowest level that captures the behavior)
- Run tests after every change

## Code Quality
- Review across five axes: correctness, readability, architecture, security, performance
- Every PR must pass: lint, type check, tests, build
- No secrets in code or version control

## Implementation
- Build in small, verifiable increments
- Each increment: implement -> test -> verify -> commit
- Never mix formatting changes with behavior changes

## Boundaries
- Always: Run tests before commits, validate user input
- Ask first: Database schema changes, new dependencies
- Never: Commit secrets, remove failing tests, skip verification
```

### Agent Personas

Copilot supports specialized agent personas. Copy the agent definitions from this repo:

```bash
# Create agents directory
mkdir -p .github/agents

# Copy agent definitions
cp /path/to/super-agent-skills/agents/code-reviewer.md .github/agents/code-reviewer.md
cp /path/to/super-agent-skills/agents/test-engineer.md .github/agents/test-engineer.md
cp /path/to/super-agent-skills/agents/security-auditor.md .github/agents/security-auditor.md
```

Invoke agents in Copilot Chat:
- `@code-reviewer Review this PR`
- `@test-engineer Analyze test coverage for this module`
- `@security-auditor Check this endpoint for vulnerabilities`

### Custom Instructions (User Level)

For skills you want across all repositories:

1. Open VS Code -> Settings -> GitHub Copilot -> Custom Instructions
2. Add summaries of your most-used skill rules

## Driving the Orchestration Chain

In Copilot, the orchestration chain does not run automatically. Drive it manually by referencing skills in sequence:

1. "Follow the brainstorming skill to explore this feature idea" -> produces design spec
2. "Now use the writing-plans skill to break this into tasks" -> produces task breakdown
3. Implement each task (Copilot follows `.github/copilot-instructions.md` for TDD + incremental rules)
4. "Use the code-reviewer agent to review my changes" -> five-axis review
5. Create PR and merge

Paste skill content into Copilot Chat when you need a specific workflow that is not covered by the always-loaded instructions.

## Using References

Paste reference checklists into Copilot Chat for detailed verification:

| Reference | When to Use |
|-----------|-------------|
| `references/testing-patterns.md` | Designing test suites, writing tests |
| `references/security-checklist.md` | Building auth, handling user input |
| `references/performance-checklist.md` | Optimizing performance |
| `references/accessibility-checklist.md` | Building UI components |

## Usage Tips

1. **Keep instructions concise** -- Copilot instructions work best when focused. The `.github/copilot-instructions.md` should summarize key rules, not include full skill files.
2. **Use agents for review** -- The code-reviewer, test-engineer, and security-auditor agents are designed for Copilot's agent model and give structured, multi-axis feedback.
3. **Paste skills into chat** -- When working on a specific phase (brainstorming, planning, debugging), paste the relevant SKILL.md content into Copilot Chat for full workflow guidance.
4. **Combine with PR reviews** -- Set up Copilot to review PRs using the code-reviewer agent persona for consistent quality gates.
5. **Load skills selectively** -- Do not paste all 24 skills. Choose the 2-3 most relevant to your current task.

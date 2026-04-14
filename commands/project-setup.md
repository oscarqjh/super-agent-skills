---
description: Scan project and generate CLAUDE.md — only includes what Claude can't infer from code
disable-model-invocation: true
---

Invoke the `super-agent-skills:project-setup` skill.

Scan the current project's codebase and generate a lean CLAUDE.md (under 100 lines) with non-obvious commands, unconventional patterns, and gotchas. Present for review before writing.

Use argument as focus area if provided: $ARGUMENTS

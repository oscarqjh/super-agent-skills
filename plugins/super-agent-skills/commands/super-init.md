---
description: Scan a project to GENERATE a new CLAUDE.md, or AUDIT an existing one against a quality rubric — only includes what Claude can't infer from code
disable-model-invocation: true
---

Invoke the `super-agent-skills:super-init` skill.

If the project has no `./CLAUDE.md`, the skill enters the GENERATE branch: it scans the codebase, picks an appropriate template (minimal-root / comprehensive-root / package / monorepo), drafts a CLAUDE.md (target <=100 lines), self-scores it against the 6-criterion quality rubric, and writes after explicit approval. Prints a one-shot onboarding panel after the first-time write.

If the project already has a `./CLAUDE.md`, the skill enters the AUDIT branch: it scores the existing file, computes a section-keyed diff of stale lines and missing additions, and applies only the patches the user approves — without overwriting untouched sections.

Use argument as focus area if provided: $ARGUMENTS

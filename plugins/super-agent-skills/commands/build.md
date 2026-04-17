---
description: Execute the implementation plan using subagent-driven development
---

Invoke the `super-agent-skills:subagent-driven-development` skill.

Load the plan, extract all tasks, dispatch a fresh subagent per task with two-stage review (spec compliance then code quality). After all tasks, run full test suite and self-review before final code review.

Use argument as plan reference if provided: $ARGUMENTS

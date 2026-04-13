#!/usr/bin/env bash
# Session start hook for super-agent-skills plugin
# Injects the using-skills meta skill into every new session

cat <<'HOOK_OUTPUT'
<IMPORTANT>
You have super-agent-skills installed.

**Below is the full content of your 'super-agent-skills:using-skills' skill — your introduction to using skills. For all other skills, use the 'Skill' tool:**

Invoke the `super-agent-skills:using-skills` skill now to load the full skill discovery and orchestration guidance.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.
</IMPORTANT>
HOOK_OUTPUT

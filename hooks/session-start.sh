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

# Check for CLAUDE.md in the project
if [ ! -f "CLAUDE.md" ] && [ ! -f ".claude/CLAUDE.md" ]; then
  cat <<'SETUP_MSG'

<IMPORTANT>
No CLAUDE.md found in this project. You MUST ask the user:
"I notice this project doesn't have a CLAUDE.md yet. Would you like me to scan your project and set one up? It helps me understand your tech stack, conventions, and commands so I can work more effectively. (Run /super-agent-skills:project-setup)"
Wait for the user's response before proceeding with any other work.
</IMPORTANT>
SETUP_MSG
fi

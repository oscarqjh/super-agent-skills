---
name: plugin-audit
description: Check installed plugins for conflicts with super-agent-skills and suggest complementary MCP servers. Use to optimize your plugin setup.
---

# Plugin Audit

Check your Claude Code environment for plugin conflicts, identify complements, and suggest MCP servers that would enhance your workflow.

**This is advisory only.** The audit reports findings and recommendations. It does NOT make any changes — you decide what to act on.

**Announce at start:** "I'm running a plugin audit to check for conflicts and suggest improvements."

## The Audit Process

### Step 1: Check for Conflicts

Run `/plugin` or check settings to identify installed plugins. Flag any that overlap with super-agent-skills:

**Known conflicts:**

| Plugin | Conflict | Recommendation |
|--------|----------|---------------|
| `superpowers` | Overlaps entirely — orchestration chain, TDD, debugging, code review | Disable. super-agent-skills replaces it completely. |
| `agent-skills` | Overlaps entirely — engineering standards, domain skills | Disable. super-agent-skills replaces it completely. |

**How to check:**
```bash
# List installed plugins (via Claude Code)
# Check /plugin → Installed tab
# Or check ~/.claude/settings.json for enabledPlugins
```

Report format:
```
⚠️  CONFLICTS (recommend disabling):
- [plugin]@[marketplace] — [reason]
  → Disable: /plugin disable [plugin]@[marketplace]
```

If no conflicts found:
```
✅ No conflicting plugins found.
```

### Step 2: Identify Complements Already Installed

Check for plugins and MCP servers that enhance super-agent-skills:

**Known complements:**

| Plugin/MCP | Enhances | Benefit |
|-----------|----------|---------|
| `context7` (plugin or MCP) | source-driven-development | Real-time documentation |
| `github` (plugin) | All skills | Issue/PR integration |
| `sentry` (MCP) | systematic-debugging | Production error data |
| Browser MCP | browser-testing-with-devtools | Automated browser testing |
| PostgreSQL MCP | api-and-interface-design | Schema exploration |
| `frontend-design` (plugin) | frontend-ui-engineering | Design system guidance |
| `code-review` (plugin) | requesting-code-review | Additional review tooling |
| TypeScript LSP (plugin) | All TypeScript work | Code intelligence |

**How to check MCP:**
```bash
# Check configured MCP servers
# /mcp command in Claude Code
# Or check .mcp.json files
```

Report format:
```
✅ COMPLEMENTS (already installed):
- [name] — enhances [skill]
```

### Step 3: Suggest Missing Complements

Based on the project type, suggest MCP servers that would help:

**Detection logic:**
- Has `package.json` → suggest Context7, TypeScript LSP
- Has `.py` files → suggest Python LSP
- Has database config → suggest PostgreSQL/MySQL MCP
- Has `.env` with SENTRY_DSN → suggest Sentry MCP
- Has UI components → suggest Browser MCP, frontend-design plugin
- Is a GitHub repo → suggest GitHub plugin

Report format:
```
💡 SUGGESTED (not installed):
- [name] — [what it does for you]
  → Install: [exact command]
```

If nothing to suggest:
```
✅ Your setup looks complete for this project.
```

### Step 4: Present Summary

Combine all findings into a single report:

```markdown
# Plugin Audit Report

## ⚠️  Conflicts
[list or "None found"]

## ✅ Complements Installed
[list or "None detected"]

## 💡 Suggested Additions
[list or "Setup looks complete"]

## Actions
[Numbered list of recommended actions, most important first]
```

## When NOT to Use

- You just installed the plugin and haven't started working yet — run project-setup first
- You're in the middle of implementation — audit between tasks, not during

## Anti-Rationalizations

| Thought | Reality |
|---------|---------|
| "I'll check my plugins later" | Conflicting plugins cause subtle issues (duplicate skills, conflicting advice). Check now. |
| "I don't need MCP servers" | You don't need them, but they make skills significantly more effective. A 5-minute setup pays off across every session. |
| "More plugins is better" | Conflicting plugins are worse than fewer plugins. Quality over quantity. |

## Red Flags

- superpowers AND super-agent-skills both enabled (duplicate orchestration)
- agent-skills AND super-agent-skills both enabled (duplicate domain skills)
- No MCP servers configured in a project with database/API/frontend work
- Multiple review plugins potentially giving conflicting feedback

## Verification

After running the audit:

- [ ] Conflict check completed (known conflicts scanned)
- [ ] Complement check completed (installed enhancers identified)
- [ ] Suggestions provided based on project type
- [ ] All recommendations include specific install/disable commands
- [ ] Report presented as advisory — no changes made automatically

# super-agent-skills

**One command. Full lifecycle.** An opinionated Claude Code plugin that turns "I want to build X" into shipped code — with specs, plans, tests, reviews, and documentation along the way.

Just type `/superthink` and the plugin handles the rest.

```
/superthink I want to build a task management API
```

The agent brainstorms the design, writes the spec, plans the implementation, dispatches subagents to build it, runs code reviews, and prompts you when it's ready to ship. Every step follows production-grade engineering standards — TDD, 5-axis code review, STRIDE threat modeling, anti-rationalization tables that catch when the agent tries to cut corners.

## Install

```bash
# From marketplace
/plugin marketplace add oscarqjh/super-agent-skills
/plugin install super-agent-skills@oscarqjh-super-agent-skills

# Or load locally
git clone https://github.com/oscarqjh/super-agent-skills.git
claude --plugin-dir ./super-agent-skills
```

> **SSH errors?** The marketplace clones via SSH. Either [add your SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh) or run: `git config --global url."https://github.com/".insteadOf "git@github.com:"`

> **Replaces** both `superpowers` and `agent-skills`. Do not install either alongside this plugin. Run `/super-agent-skills:audit` to check for conflicts.

## Setup Guides

| Environment | Guide |
|-------------|-------|
| **Claude Code** | [docs/claude-code-setup.md](docs/claude-code-setup.md) |
| **Cursor** | [docs/cursor-setup.md](docs/cursor-setup.md) |
| **OpenCode** | [docs/opencode-setup.md](docs/opencode-setup.md) |
| **Gemini CLI** | [docs/gemini-cli-setup.md](docs/gemini-cli-setup.md) |
| **Windsurf** | [docs/windsurf-setup.md](docs/windsurf-setup.md) |
| **GitHub Copilot** | [docs/copilot-setup.md](docs/copilot-setup.md) |
| **Any agent** | [docs/getting-started.md](docs/getting-started.md) |

## How It Works

`/superthink` classifies your intent and routes to the right workflow:

```
/superthink [what you want to do]
        │
        ├── "build X" ──────── Full lifecycle chain (see below)
        ├── "fix X" ────────── Root-cause debugging (not guessing)
        ├── "review code" ──── 5-axis code review
        ├── "test X" ───────── TDD with spec-driven test generation
        ├── "simplify X" ──── Reduce complexity, preserve behavior
        ├── "ship it" ──────── Pre-merge checklist → merge/PR
        └── "plan X" ───────── Task breakdown with dependency graphs
```

### The Build Chain

When you're building something new, the plugin runs the complete lifecycle:

```
① Brainstorming          Ask questions, explore approaches, write design spec
        │                 + generates acceptance test skeletons
        ▼                 + invokes threat-modeling if security-sensitive
② Writing Plans          Break spec into bite-sized tasks with vertical slicing
        │                 + maps dependency graph, adds checkpoints
        ▼                 + suggests compound-engineering if multi-stream
③ Building               Dispatch fresh subagent per task (TDD, incremental)
        │                 + domain skills auto-trigger: API, frontend, security...
        │                 + parallel dispatch for independent tasks (max 3)
        ▼                 + spec compliance review + code quality review per task
④ Code Review            5-axis review with self-healing fix loop (3 rounds)
        │                 + architecture reviewer for design-significant changes
        ▼
⑤ You Choose             "Wrap up" (commit + next task) OR "Ship it" (merge/PR)
```

Every step has anti-rationalization tables that catch shortcuts, and hooks that enforce handoffs. See [Architecture](docs/architecture.md) for the complete process graph with all skills, agents, and hooks.

## What's Inside

29 skills, 7 agent personas, 6 reference guides, 12 slash commands, 4 hook types.

See [Architecture](docs/architecture.md) for the full inventory and how everything connects.



## Documentation

- [Architecture](docs/architecture.md) — process graph, skill inventory, hook system
- [Example Workflows](docs/example-workflows.md) — end-to-end usage examples
- [Skill Authoring Guide](docs/skill-authoring-guide.md) — how to create new skills
- [Contributing](CONTRIBUTING.md) — how to contribute to this plugin
- [Changelog](CHANGELOG.md) — release history
- [MCP Integrations](references/mcp-integrations.md) — recommended MCP servers

## Credits

This plugin combines the best of two worlds:
- [superpowers](https://github.com/obra/superpowers) by Jesse Vincent — the process orchestration (brainstorm → plan → build → review → ship chain, subagent dispatch, worktree management)
- [agent-skills](https://github.com/addyosmani/agent-skills) by Addy Osmani — the engineering rigour (TDD discipline, OWASP security, 5-axis code review, Hyrum's Law, anti-rationalization tables)

On top of the merge, super-agent-skills adds: deterministic chain enforcement via hooks, a wrap-up skill for lightweight checkpointing, compound engineering for multi-stream parallel development, STRIDE threat modeling, project-setup with organic CLAUDE.md growth, plugin audit for conflict detection, and a `/superthink` universal entry point that makes it all work with one command.

## License

MIT

## License

MIT

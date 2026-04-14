# MCP Integrations Reference

MCP (Model Context Protocol) servers connect Claude Code to external data sources. These servers complement super-agent-skills by providing real-time data that skills can't access on their own.

## Recommended MCP Servers

### Context7 — Real-Time Documentation

**Complements:** `super-agent-skills:source-driven-development`, `super-agent-skills:frontend-ui-engineering`, `super-agent-skills:api-and-interface-design`

**What it does:** Fetches current documentation directly from library source repositories. Ensures Claude uses up-to-date API patterns instead of stale training data.

**When it matters:** Working with rapidly evolving frameworks (React, Next.js, Tailwind, etc.) where APIs change between versions.

**Install:**
```bash
claude mcp add context7 -- npx -y @upstash/context7-mcp
```

### Sentry — Error Tracking

**Complements:** `super-agent-skills:systematic-debugging`

**What it does:** Brings production error data directly into Claude's context — stack traces, frequency, affected users, first/last seen.

**When it matters:** Debugging production issues. Instead of asking the user to paste error logs, Claude queries Sentry directly.

**Install:**
```bash
claude mcp add sentry -- npx -y @sentry/mcp-server
```

**Requires:** `SENTRY_AUTH_TOKEN` environment variable.

### Browser Automation — Playwright/Puppeteer

**Complements:** `super-agent-skills:browser-testing-with-devtools`, `super-agent-skills:frontend-ui-engineering`

**What it does:** Navigate pages, click elements, fill forms, take screenshots, read console output — all from Claude Code.

**When it matters:** Testing UI changes, debugging visual issues, verifying frontend behavior.

**Install:**
```bash
claude mcp add browser -- npx -y @anthropic/mcp-browser
```

### PostgreSQL — Database Access

**Complements:** `super-agent-skills:api-and-interface-design`, `super-agent-skills:systematic-debugging`

**What it does:** Query databases, explore schemas, understand table relationships, run diagnostic queries.

**When it matters:** Designing data models, debugging data-related bugs, understanding existing schema.

**Install:**
```bash
claude mcp add postgres -- npx -y @anthropic/mcp-postgres
```

**Requires:** `DATABASE_URL` environment variable.

### GitHub — Repository Integration

**Complements:** All skills (issue tracking, PR context, code search across repos)

**What it does:** Read issues, review PRs, search repositories, access commit history — without leaving Claude Code.

**When it matters:** Working with GitHub-hosted projects. Already available as an official plugin.

**Install:**
```bash
/plugin install github@claude-plugins-official
```

## How Skills Use MCP

Skills don't require MCP servers — they work without them. But when MCP servers are available, skills become more effective:

| Skill | Without MCP | With MCP |
|-------|------------|----------|
| source-driven-development | Relies on training data (may be outdated) | Context7 fetches current docs |
| systematic-debugging | User pastes error logs manually | Sentry provides production error data |
| browser-testing-with-devtools | Guides user to check browser manually | Browser MCP automates testing |
| api-and-interface-design | Designs from spec only | PostgreSQL shows actual schema |

## Checking Your MCP Setup

Run `/super-agent-skills:audit` to see which MCP servers are installed and which would complement your workflow.

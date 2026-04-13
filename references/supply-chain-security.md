# Supply Chain Security Reference

Quick reference for dependency auditing, license compliance, and AI-specific security. Use alongside the `super-agent-skills:security-and-hardening` skill.

## Audit Commands by Ecosystem

| Ecosystem | Audit Command | Alternative |
|-----------|--------------|-------------|
| Node.js | `npm audit` | `npx auditjs` |
| Python | `pip-audit` | `safety check` |
| Go | `govulncheck ./...` | `nancy` |
| Rust | `cargo audit` | — |
| Java | `mvn dependency-check:check` | `gradle dependencyCheckAnalyze` |
| Ruby | `bundle audit` | — |
| PHP | `composer audit` | — |

### Quick Fix Commands

```bash
# Node.js — auto-fix vulnerabilities
npm audit fix
npm audit fix --force          # includes breaking changes

# Node.js — filter by severity
npm audit --audit-level=critical

# Node.js — check for outdated packages
npx npm-check-updates

# Python — auto-fix
pip-audit --fix

# Rust — auto-fix
cargo audit fix
```

## License Compatibility Matrix

| License | Type | Safe for proprietary? | Notes |
|---------|------|----------------------|-------|
| MIT | Permissive | Yes | No restrictions |
| Apache-2.0 | Permissive | Yes | Must include license/notice |
| BSD-2/3 | Permissive | Yes | Must include copyright |
| ISC | Permissive | Yes | Simplified MIT |
| LGPL | Weak copyleft | Yes (if dynamically linked) | Risky if statically linked or bundled |
| MPL-2.0 | Weak copyleft | Yes (file-level) | Modified files must stay MPL |
| GPL-2.0/3.0 | Strong copyleft | No | Entire project must be GPL |
| AGPL-3.0 | Network copyleft | No | Extends to SaaS/network use |
| Unlicensed | None | No | No permission granted — do not use |

**When in doubt:** Check with legal. License violations have real consequences.

## Lockfile Hygiene

- **Always commit lockfiles**: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Pipfile.lock`, `go.sum`, `Cargo.lock`
- **Review lockfile diffs in PRs**: unexpected changes may indicate dependency confusion or tampering
- **Use frozen installs in CI**: `npm ci`, `yarn --frozen-lockfile`, `pip install --require-hashes`
- **Regenerate periodically**: run `npm update` / `pip-compile --upgrade` on a schedule to pick up patches

## Pre-Install Checklist

Before adding any dependency:

- [ ] Package name spelled correctly (no typosquatting: `lodash` not `1odash`)
- [ ] Published by expected maintainer (check npm/PyPI page)
- [ ] Last updated within 12 months
- [ ] No known CVEs (`npm audit` / `pip-audit` clean after adding)
- [ ] License compatible with project (see matrix above)
- [ ] Bundle size acceptable (check `bundlephobia.com` for JS packages)
- [ ] No excessive transitive dependencies (check `npm ls --all` depth)
- [ ] README and docs exist (abandoned packages often lack these)

## Typosquatting Detection

Common patterns to watch for:
- Letter swaps: `lodash` vs `1odash`, `@babel/core` vs `@bable/core`
- Scope hijacking: `@company/util` vs `@c0mpany/util`
- Extra/missing hyphens: `react-dom` vs `reactdom` vs `react--dom`
- Similar names: `colors` vs `colour` vs `colores`

**Always verify on the official registry page before installing.**

## AI-Specific Security Checklist

When building applications that use LLMs or AI models:

### Prompt Security
- [ ] User input never directly concatenated into system prompts
- [ ] Prompt templates use parameterized injection points (not string concatenation)
- [ ] System prompts are not exposed to end users
- [ ] Prompt injection testing is part of the test suite

### Output Validation
- [ ] LLM output validated before use in SQL queries
- [ ] LLM output sanitized before rendering as HTML (prevent XSS)
- [ ] LLM output not passed to shell commands without sanitization
- [ ] LLM output not used as file paths without validation
- [ ] Output length limits prevent resource exhaustion

### Model Supply Chain
- [ ] Model files verified by checksum before loading
- [ ] Models downloaded from trusted sources only (official registries)
- [ ] No execution of code embedded in model files
- [ ] API keys for AI services stored in environment variables, not code

### Rate Limiting
- [ ] Rate limiting on LLM-facing endpoints to prevent abuse
- [ ] Cost monitoring and alerts for API-based LLM usage
- [ ] Token limits per request to prevent context window stuffing

## Common Supply Chain Attacks

| Attack | How it works | Prevention |
|--------|-------------|-----------|
| Typosquatting | Malicious package with similar name | Verify exact name on registry |
| Dependency confusion | Public package shadows private one | Use scoped packages, configure registries |
| Maintainer takeover | Attacker gains publish access | Pin versions, review lockfile diffs |
| Build script injection | Malicious postinstall script | Use `--ignore-scripts`, review scripts |
| Star jacking | Fake popularity metrics | Check actual download numbers, not just stars |

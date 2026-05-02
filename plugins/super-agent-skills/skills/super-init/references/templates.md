# CLAUDE.md Templates

Four named templates `super-init` chooses between based on project layout. Each template is a section structure, not a fully filled draft — the skill fills it from scan results.

## Template: minimal-root

Target line count: ~30-50.

For thin single-manifest repos. Auto-picked when:
- Exactly one manifest at root (one of `package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod` / `pom.xml` / `requirements.txt`).
- Fewer than 10 source files for the primary language (see "Auto-detection rules" below).
- Zero significant subdirectories (see "Auto-detection rules" below).

```markdown
# Project: <name>

## Commands
- <only non-obvious>

## Conventions
- <only conventions that differ from defaults>

## Gotchas
<!-- Add here when Claude makes wrong assumptions -->
```

## Template: comprehensive-root

Target line count: ~60-90.

Default fallback for single-root non-monorepo projects that don't qualify for `minimal-root`.

```markdown
# Project: <name>

## Commands
- Build: <only if non-obvious>
- Test: <only if non-obvious>
- Lint: <only if non-obvious>
- Dev: <only if non-obvious>
- Type check: <only if non-obvious>

## Conventions
- <only conventions that differ from defaults>

## Architecture
- <only non-obvious structural decisions>

## Boundaries
- Always: <project-specific musts>
- Ask first: <things that need human approval>
- Never: <hard rules>

## Gotchas
<!-- Add here when Claude makes wrong assumptions -->
```

## Template: package

Target line count: ~40-70.

For when the cwd is inside a package of a workspace (e.g. `packages/<X>/`).

```markdown
# Package: <X>

## Overview
- <one or two sentences: what this package does in the workspace>

## Commands (package-level)
- <only non-obvious package-scoped commands>

## Conventions
- <package-specific conventions that differ from workspace-shared ones>

## Boundaries vs Sibling Packages
- <what this package may import / must not import>
- <which package owns shared types / utils>

## Gotchas
<!-- Add here when Claude makes wrong assumptions -->
```

## Template: monorepo

Target line count: ~70-100.

For the repo root of a monorepo.

```markdown
# Monorepo: <name>

## Workspace Layout
- packages/* — <one-line summary>
- apps/* — <one-line summary>
- <other workspace roots>

## Cross-package Commands
- <only commands that operate across the workspace>

## Shared Conventions
- <conventions that apply to every package>

## Per-package Boundaries
- See `.claude/rules/` for path-scoped rules per package (if scaffolded).

## Gotchas
<!-- Add here when Claude makes wrong assumptions -->
```

## Auto-detection Rules

The skill body runs these checks at GENERATE step 5 (layout detect + template pick).

### Source file count
"Source file" = any tracked file (`git ls-files`) whose extension matches the project's primary-language inference from manifest:

| Manifest signal | Primary extensions |
|------------------|---------------------|
| `package.json` | `.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.cjs` |
| `pyproject.toml` / `requirements.txt` | `.py` |
| `Cargo.toml` | `.rs` |
| `go.mod` | `.go` |
| `pom.xml` / `build.gradle` | `.java`, `.kt` |

`< 10` such files contributes to the `minimal-root` signal.

### Significant subdirectory exclude set
A directory at the repo root is "significant" only if its name is **not** in:
`{ node_modules, dist, build, .git, .next, .nuxt, target, vendor, __pycache__, .venv, venv, coverage, out, .cache }`.

Zero significant subdirectories contributes to the `minimal-root` signal.

### Monorepo signals (any one is sufficient)
- A `packages/` directory at root.
- An `apps/` directory at root.
- A `workspaces` field in `package.json`.
- A `lerna.json` file at root.
- A `pnpm-workspace.yaml` file at root.

### Package signals (both required)
- The cwd is inside `packages/<X>/` (one path segment under `packages/`).
- A workspace ancestor exists (one of the monorepo signals at an ancestor directory).

### Minimal-root signals (all three required)
- Exactly one manifest at root.
- Fewer than 10 source files (per the source-file count rule).
- Zero significant subdirectories (per the exclude-set rule).

### Comprehensive-root
Default fallback. Used when none of `monorepo` / `package` / `minimal-root` matches.

## Override

After auto-pick, the skill presents the chosen template name with a one-line rationale and accepts a user override of any of the 4 templates at the draft-review step (GENERATE step 7).

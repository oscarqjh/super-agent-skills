# CLAUDE.md Update Guidelines

Used by `super-init`'s AUDIT branch to format proposed patches against an existing CLAUDE.md, and by the GENERATE branch as a pre-write self-check on the draft (the "what NOT to add" list).

## Diff Format (AUDIT)

### Section-keyed hunks
Patches are grouped by the H2 (`##`) or H3 (`###`) heading they touch. One approval prompt is shown per touched section. Sections the diff did not touch are never displayed and are left untouched on apply.

### Within a section: unified-diff
Inside each section's hunk, line-level changes use unified-diff style: lines prefixed `-` are removed, lines prefixed `+` are added, lines with no prefix are context. Replacements appear as a `-` line immediately followed by a `+` line. The first character of each line in the diff codeblock is the diff marker; everything after the first space is the file's original content (which may itself begin with markdown punctuation like `-` for a list item).

### Worked Example

Existing CLAUDE.md fragment:
```markdown
## Commands
- Build: `npm run build`
- Test: `npm test`

## Gotchas
- Always run `npm install` first
```

Scan finds: project switched from npm to pnpm; `pnpm-lock.yaml` is at root; `package.json` has script `test:unit`.

Diff hunks emitted:
```diff
## Commands
- - Build: `npm run build`
- - Test: `npm test`
+ - Build: `pnpm build`
+ - Test: `pnpm test:unit`
```
```diff
## Gotchas
- - Always run `npm install` first
+ - Use `pnpm`, not `npm` (see `pnpm-lock.yaml` at root)
```

User approval prompt:
```
Section: ## Commands — apply this hunk? [y/n/skip-all]
Section: ## Gotchas — apply this hunk? [y/n/skip-all]
```

The user can also approve all touched sections in bulk: `[Y to apply every hunk]`. Unapproved hunks are dropped — the file is patched only with the approved hunks. The `## Architecture` and `## Conventions` sections in the existing file (untouched by the diff) are never shown and never modified.

## What NOT to Add

The skill must reject any of the following from inclusion at GENERATE draft-time and from AUDIT additions:

- **Boilerplate** — generic "remember to run tests before merging", "follow the style guide".
- **File-by-file descriptions** — Claude can read the file tree.
- **Standard framework conventions** — "React uses JSX", "Next.js routes are file-based".
- **Generic prompts** — "be concise", "do your best work".
- **Restated defaults** — anything the language/framework already enforces.

If a candidate line fails the Golden Rule ("would removing this cause Claude to make a mistake?"), it belongs on this list, not in the file.

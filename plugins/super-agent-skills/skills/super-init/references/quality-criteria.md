# CLAUDE.md Quality Criteria

The 6-criterion rubric used by `super-init` to score CLAUDE.md drafts (GENERATE) and existing files (AUDIT). Total: 100 points.

## Criteria and Weights

| # | Criterion | Weight | Question |
|---|-----------|:-----:|----------|
| 1 | Correctness | 20 | Are claims accurate? Are commands runnable as-written? |
| 2 | Conciseness | 20 | Does every line pass the Golden Rule ("would removing it cause Claude to make a mistake?")? Is the file under the 100-line budget? |
| 3 | Gotchas | 15 | Are non-obvious traps recorded? Is a Gotchas section present (even if empty)? |
| 4 | Conventions | 15 | Are only conventions that differ from language/framework defaults listed? |
| 5 | Commands | 15 | Are only commands Claude couldn't guess included? Are they runnable verbatim? |
| 6 | Structure | 15 | Does the file use the right template for the layout? Does section ordering match the chosen template? |

## Grade Thresholds

| Grade | Score |
|:-----:|------|
| A | ≥ 85 |
| B | ≥ 70 |
| C | ≥ 55 |
| F | < 55 |

GENERATE drafts target grade ≥ B before write. AUDIT reports the grade alongside the diff so the user sees the score impact.

## Scoring Guidance

### Correctness (20)
Score 20 if every command and claim is verifiable against the scan results. Subtract 5 per stale command (e.g. `npm run build` listed but `package.json` has no `build` script). Subtract 5 per factually wrong architectural claim. Floor: 0.

Examples:
- A file claiming "uses pnpm" while `pnpm-lock.yaml` is absent and `package-lock.json` is present → −10.
- A file listing `make test` when no `Makefile` exists → −5.
- A file noting "TypeScript strict mode" and `tsconfig.json` confirms `"strict": true` → +20.

### Conciseness (20)
Score 20 if file is ≤ 100 lines and every retained line passes the Golden Rule. Subtract 1 per line over 100 (cap −10). Subtract 2 per Golden-Rule-violating line (boilerplate, defaults restated). Floor: 0.

Examples:
- 60-line file, every line earns its keep → 20.
- 130-line file with 5 default-restating lines → −10 (over budget) − 10 (5 violations × 2) = 0.
- 90-line file with 2 framework-default lines → −4 = 16.

### Gotchas (15)
Score 15 if a Gotchas section exists AND at least one non-obvious trap is recorded (or, for a brand-new project, the section is present and empty as a placeholder for organic growth). Subtract 5 if the section is missing. Subtract 5 per Gotcha that is actually a default (e.g. "remember to run `npm install`").

Examples:
- Section exists, lists "Build skips /vendor; do not edit there" → 15.
- Section exists, lists "Run npm install first" → 15 − 5 = 10.
- No Gotchas section → −15 → 0.

### Conventions (15)
Score 15 if every convention listed differs from defaults. Subtract 3 per convention that's a language/framework default (e.g. "use ES modules in a Node 18 project").

Examples:
- "Class components, not functional" in a React project → +15 (unusual).
- "Use functional components" in a React project → −3 (default).
- "PRs must use Conventional Commits" if `git log` confirms → +15.

### Commands (15)
Score 15 if every command is non-guessable AND verbatim runnable. Subtract 3 per guessable command (`npm test`, `cargo build`). Subtract 5 per non-runnable command (typo, missing flag the project actually requires).

Examples:
- `pnpm --filter web test:unit -- --coverage --bail` → +15.
- `npm test` listed → −3.
- `nm run build` (typo) → −5.

### Structure (15)
Score 15 if the chosen template matches layout signals AND section ordering matches the template definition in `templates.md`. Subtract 5 if the wrong template was used. Subtract 3 per out-of-order section.

Examples:
- Monorepo project, monorepo template chosen, sections in order → 15.
- Single-manifest 5-file repo using comprehensive-root template → −5.
- Right template but Conventions before Commands when template orders Commands first → −3.

## How the Skill Cites This File

The skill body cites this file at the GENERATE draft self-score step (step 6) and at the AUDIT score step (step 3). Both cite the file by relative path: `references/quality-criteria.md`.

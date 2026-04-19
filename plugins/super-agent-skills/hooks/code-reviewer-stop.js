#!/usr/bin/env node
// SubagentStop hook for super-agent-skills:code-reviewer.
//
// After a review finishes, the subagent must emit the sentinel
// [AWAITING_USER_CHOICE] followed by the A/B/C completion menu. This hook
// enforces that contract without risking an infinite stop loop.
//
// Loop-safety contract, in order:
//   1. Malformed JSON on stdin   -> exit 0 silently.
//      (We cannot read stop_hook_active, so blocking could loop.)
//   2. stop_hook_active === true -> exit 0 silently.
//      (Second pass after a previous block; never block twice.)
//   3. last_assistant_message contains the sentinel -> exit 0 silently.
//   4. Otherwise                 -> emit decision:block once, teaching the
//      subagent the exact sentinel + menu to append.
//
// The sentinel is a literal substring match — no regex false positives.

const SENTINEL = '[AWAITING_USER_CHOICE]';

let input = '';
process.stdin.on('error', () => process.exit(0));
process.stdin.on('data', (chunk) => { input += chunk; });
process.stdin.on('end', () => {
  let data;
  try { data = JSON.parse(input); } catch (_) {
    process.exit(0);
  }

  if (data.stop_hook_active === true) {
    process.exit(0);
  }

  const last = String(data.last_assistant_message || '');
  if (last.includes(SENTINEL)) {
    process.exit(0);
  }

  const reason =
    'Code review finished but the completion menu is missing. ' +
    'Append this exact block to your response, verbatim, on its own lines, ' +
    'with nothing after it:\n\n' +
    SENTINEL + '\n' +
    '(A) Wrap up — update backlog, changelog, commit, move to next item\n' +
    '(B) Ship it — pre-merge checklist, merge/PR, branch cleanup\n' +
    '(C) Keep going — continue working\n\n' +
    'The sentinel on the first line is required.';

  process.stdout.write(JSON.stringify({ decision: 'block', reason }));
  process.exit(0);
});

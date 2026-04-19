#!/usr/bin/env node
// SubagentStop hook — enforces the A/B/C completion prompt after a code review
// without causing an infinite stop loop. See code-reviewer-stop.sh for the
// full contract.

let input = '';
process.stdin.on('data', (chunk) => { input += chunk; });
process.stdin.on('end', () => {
  let data;
  try { data = JSON.parse(input); } catch (_) {
    // Malformed hook input: exit silently so we never block on garbage.
    // Blocking here would risk an infinite loop since stop_hook_active
    // cannot be read from an unparsable payload.
    process.exit(0);
  }

  if (data.stop_hook_active === true) {
    process.exit(0);
  }

  const last = String(data.last_assistant_message || '');
  // Accept either "(A)" or "A)" prefixes. Require all three markers in order.
  const menuPattern = /\(?A\)[\s\S]*?\(?B\)[\s\S]*?\(?C\)/;
  if (menuPattern.test(last)) {
    process.exit(0);
  }

  const reason =
    'Code review finished. Before stopping you must prompt the user with ' +
    'completion options: (A) Wrap up — update backlog, changelog, commit, ' +
    'move to next item. (B) Ship it — pre-merge checklist, merge/PR, branch ' +
    'cleanup. (C) Keep going — continue working. Present these options and ' +
    "wait for the user's response before taking any action.";

  process.stdout.write(JSON.stringify({ decision: 'block', reason }));
  process.exit(0);
});

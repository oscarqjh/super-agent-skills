#!/usr/bin/env node

/**
 * generate-capability-index.js
 *
 * Parses YAML frontmatter from all skills/<name>/SKILL.md files and generates:
 * 1. generated/session-start-capabilities.md — compact companion tools table
 * 2. generated/routing-table.md — full routing table for using-skills
 * 3. generated/when-to-use-suggestions.md — suggested when_to_use values
 *
 * Also updates skills/using-skills/SKILL.md in-place between marker comments.
 */

const fs = require('fs');
const path = require('path');

const SKILLS_DIR = path.join(__dirname, '..', 'skills');
const GENERATED_DIR = path.join(__dirname, '..', 'generated');
const VALID_PHASES = ['define', 'plan', 'build', 'verify', 'review', 'ship', 'support', 'meta'];

// Fields we parse. Claude Code fields like 'hooks', 'allowed-tools', 'model' etc.
// have complex nested structures we don't need — skip them entirely.
const CUSTOM_FIELDS = ['phase', 'produces', 'requires', 'companions', 'chainsTo', 'chainsFrom', 'autoTriggers'];
const PASSTHROUGH_FIELDS = ['name', 'description', 'when_to_use'];

// --- YAML Frontmatter Parser ---

function parseFrontmatter(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return null;
  return parseYaml(match[1]);
}

function parseYaml(yaml) {
  const result = {};
  const lines = yaml.split('\n');
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];

    // Skip empty lines and comments
    if (!line.trim() || line.trim().startsWith('#')) {
      i++;
      continue;
    }

    // Top-level key: value
    const kvMatch = line.match(/^(\w[\w-]*)\s*:\s*(.+)$/);
    if (kvMatch) {
      const key = kvMatch[1];
      let value = kvMatch[2].trim();
      // Remove quotes
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.slice(1, -1);
      }
      // Inline array: [a, b, c]
      if (value.startsWith('[') && value.endsWith(']')) {
        value = value.slice(1, -1).split(',').map(s => s.trim().replace(/^["']|["']$/g, ''));
      }
      result[key] = value;
      i++;
      continue;
    }

    // Top-level key with block value (array or object)
    const blockMatch = line.match(/^(\w[\w-]*)\s*:\s*$/);
    if (blockMatch) {
      const key = blockMatch[1];
      i++;

      // Skip fields we don't need (e.g. hooks — complex nested YAML we can't parse)
      if (!CUSTOM_FIELDS.includes(key) && !PASSTHROUGH_FIELDS.includes(key)) {
        // Fast-forward past indented block
        while (i < lines.length && (lines[i].startsWith(' ') || lines[i].startsWith('\t') || !lines[i].trim())) {
          i++;
        }
        continue;
      }

      const blockResult = parseBlock(lines, i, 2);
      result[key] = blockResult.value;
      i = blockResult.nextIndex;
      continue;
    }

    i++;
  }

  return result;
}

function parseBlock(lines, startIndex, indent) {
  const items = [];
  let i = startIndex;

  while (i < lines.length) {
    const line = lines[i];

    // End of block: line with less indentation (non-empty, non-array)
    if (line.trim() && !line.startsWith(' '.repeat(indent)) && !line.match(/^\s*-/)) {
      break;
    }

    if (!line.trim()) {
      i++;
      continue;
    }

    // Array item: - value or - key: value
    const arrayItemMatch = line.match(/^(\s*)-\s+(.+)$/);
    if (arrayItemMatch) {
      const itemIndent = arrayItemMatch[1].length;
      let value = arrayItemMatch[2].trim();

      // Simple string item: - "value"
      if (!value.includes(':') || value.startsWith('"') || value.startsWith("'")) {
        value = value.replace(/^["']|["']$/g, '');
        items.push(value);
        i++;
        continue;
      }

      // Object item: - key: value (start of object)
      const objMatch = value.match(/^(\w[\w-]*)\s*:\s*(.+)$/);
      if (objMatch) {
        const obj = {};
        obj[objMatch[1]] = cleanValue(objMatch[2]);
        i++;

        // Read remaining object fields at deeper indentation
        while (i < lines.length) {
          const nextLine = lines[i];
          if (!nextLine.trim()) { i++; continue; }
          // Check if it's another array item at same level or top-level key
          if (nextLine.match(new RegExp(`^\\s{${itemIndent}}-`))) break;
          if (!nextLine.startsWith(' '.repeat(itemIndent + 2))) break;
          const fieldMatch = nextLine.trim().match(/^(\w[\w-]*)\s*:\s*(.+)$/);
          if (fieldMatch) {
            obj[fieldMatch[1]] = cleanValue(fieldMatch[2]);
          }
          i++;
        }
        items.push(obj);
        continue;
      }
    }

    i++;
  }

  return { value: items, nextIndex: i };
}

function cleanValue(val) {
  val = val.trim();
  if ((val.startsWith('"') && val.endsWith('"')) ||
      (val.startsWith("'") && val.endsWith("'"))) {
    val = val.slice(1, -1);
  }
  if (val === 'true') return true;
  if (val === 'false') return false;
  return val;
}

// --- Skill Discovery ---

function discoverSkills() {
  const skills = [];
  const entries = fs.readdirSync(SKILLS_DIR, { withFileTypes: true });

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    const skillPath = path.join(SKILLS_DIR, entry.name, 'SKILL.md');
    if (!fs.existsSync(skillPath)) continue;

    const content = fs.readFileSync(skillPath, 'utf-8');
    const frontmatter = parseFrontmatter(content);
    if (!frontmatter) {
      console.warn(`WARN: No frontmatter found in ${entry.name}/SKILL.md`);
      continue;
    }

    frontmatter._dir = entry.name;
    skills.push(frontmatter);
  }

  return skills;
}

// --- Validation ---

function validate(skills) {
  const skillNames = new Set(skills.map(s => s.name));
  const errors = [];
  const warnings = [];

  for (const skill of skills) {
    // Validate phase
    if (!skill.phase) {
      warnings.push(`${skill.name}: missing 'phase' field`);
    } else if (!VALID_PHASES.includes(skill.phase)) {
      errors.push(`${skill.name}: invalid phase '${skill.phase}' (must be one of: ${VALID_PHASES.join(', ')})`);
    }

    // Validate chainsTo references
    const chainsTo = Array.isArray(skill.chainsTo) ? skill.chainsTo : (skill.chainsTo ? [skill.chainsTo] : []);
    for (const ref of chainsTo) {
      if (!skillNames.has(ref)) {
        errors.push(`${skill.name}: chainsTo references non-existent skill '${ref}'`);
      }
    }

    // Validate chainsFrom references
    const chainsFrom = Array.isArray(skill.chainsFrom) ? skill.chainsFrom : (skill.chainsFrom ? [skill.chainsFrom] : []);
    for (const ref of chainsFrom) {
      // Allow 'superthink' as a special case (it's a command, not a skill)
      if (ref === 'superthink') continue;
      if (!skillNames.has(ref)) {
        errors.push(`${skill.name}: chainsFrom references non-existent skill '${ref}'`);
      }
    }

    // Check for orphaned skills (no chains, no autoTriggers, not support/meta)
    const triggers = toArray(skill.autoTriggers);
    if (chainsTo.length === 0 && chainsFrom.length === 0 && triggers.length === 0 &&
        skill.phase && !['support', 'meta'].includes(skill.phase)) {
      warnings.push(`${skill.name}: orphaned skill (no chainsTo, chainsFrom, or autoTriggers; phase: ${skill.phase})`);
    }

    // Check companion id uniqueness
    const companions = Array.isArray(skill.companions) ? skill.companions : [];
    for (const comp of companions) {
      if (comp.id) {
        const dupes = skills.filter(s =>
          Array.isArray(s.companions) && s.companions.some(c => c.id === comp.id) && s.name !== skill.name
        );
        if (dupes.length > 0) {
          warnings.push(`${skill.name}: companion id '${comp.id}' also used in: ${dupes.map(d => d.name).join(', ')}`);
        }
      }
    }

    // Warn if has companions but description doesn't mention them
    if (companions.length > 0 && skill.description) {
      for (const comp of companions) {
        if (comp.id && !skill.description.toLowerCase().includes(comp.id.replace(/-/g, ' ')) &&
            !(skill['when_to_use'] && skill['when_to_use'].toLowerCase().includes(comp.id.replace(/-/g, ' ')))) {
          warnings.push(`${skill.name}: has companion '${comp.id}' but description/when_to_use doesn't mention it (Tier 0 gap)`);
        }
      }
    }
  }

  return { errors, warnings };
}

// --- Output Generators ---

function toArray(val) {
  if (!val) return [];
  if (Array.isArray(val)) return val;
  return [val];
}

function generateSessionStartCapabilities(skills) {
  const companionSkills = skills.filter(s => Array.isArray(s.companions) && s.companions.length > 0);

  if (companionSkills.length === 0) {
    return '<!-- No companion tools found in skill frontmatter -->\n';
  }

  let output = '## Companion Tools Available\n\n';
  output += '| Skill | Companion | Type | When |\n';
  output += '|-------|-----------|------|------|\n';

  const canStatements = [];

  for (const skill of companionSkills) {
    for (const comp of skill.companions) {
      output += `| ${skill.name} | ${comp.id} | ${comp.type} | ${comp.when || '—'} |\n`;

      // Generate "You CAN" statements
      if (comp.description) {
        const prefix = comp.type === 'mcp-server' ? ' (if MCP configured)' : '';
        canStatements.push(`You CAN ${comp.description.toLowerCase()}${prefix}.`);
      }
    }
  }

  output += '\n';
  for (const stmt of canStatements) {
    output += `${stmt}\n`;
  }
  output += 'Do NOT say "I can\'t do X" for any capability listed above — invoke the skill to use it.\n';

  return output;
}

function generateRoutingTable(skills) {
  let output = '';

  // --- Skills by Phase ---
  output += '## Skills by Phase\n\n';

  for (const phase of VALID_PHASES) {
    const phaseSkills = skills.filter(s => s.phase === phase);
    if (phaseSkills.length === 0) continue;

    output += `### ${phase}\n`;
    output += '| Skill | Produces | Companions |\n';
    output += '|-------|----------|------------|\n';

    for (const skill of phaseSkills) {
      const produces = toArray(skill.produces).join(', ') || '—';
      const companions = toArray(skill.companions)
        .map(c => typeof c === 'object' ? `${c.id} (${c.type})` : c)
        .join(', ') || '—';
      output += `| ${skill.name} | ${produces} | ${companions} |\n`;
    }
    output += '\n';
  }

  // --- Workflow Chains ---
  // Hardcoded known chains — auto-discovery is fragile with a graph (cycles,
  // multi-branch, multiple entry points). These are the designed primary chains.
  // Update this list when adding new chain workflows.
  const KNOWN_CHAINS = [
    'brainstorming → writing-plans → subagent-driven-development → requesting-code-review → [wrap-up | finishing-a-development-branch]',
    'systematic-debugging → test-driven-development → verification-before-completion',
    'compound-engineering → writing-plans (per stream) → subagent-driven-development → requesting-code-review',
    'executing-plans → requesting-code-review → [wrap-up | finishing-a-development-branch]',
  ];

  output += '## Workflow Chains\n\n```\n';
  for (const chain of KNOWN_CHAINS) {
    output += chain + '\n';
  }
  output += '```\n\n';

  // --- Superthink Entry Points ---
  const superthinkTargets = skills.filter(s => {
    const from = toArray(s.chainsFrom);
    return from.includes('superthink');
  });

  if (superthinkTargets.length > 0) {
    output += '## /superthink Entry Points\n\n';
    output += '| Intent | Routes To |\n';
    output += '|--------|----------|\n';
    for (const skill of superthinkTargets) {
      output += `| (see /superthink) | ${skill.name} |\n`;
    }
    output += '\n';
  }

  // --- Auto-Triggers ---
  const autoTriggerSkills = skills.filter(s => toArray(s.autoTriggers).length > 0);

  if (autoTriggerSkills.length > 0) {
    output += '## Auto-Triggers During Implementation\n\n';
    output += '| Context Detected | Invoke |\n';
    output += '|-----------------|--------|\n';

    for (const skill of autoTriggerSkills) {
      for (const trigger of toArray(skill.autoTriggers)) {
        output += `| ${trigger} | ${skill.name} |\n`;
      }
    }
    output += '\n';
  }

  return output;
}

function generateWhenToUseSuggestions(skills) {
  let output = '# Suggested when_to_use Updates\n\n';
  output += 'Review these suggestions. Apply manually to SKILL.md frontmatter if appropriate.\n\n';

  let hasSuggestions = false;

  for (const skill of skills) {
    const companions = toArray(skill.companions);
    if (companions.length === 0) continue;

    const desc = (skill.description || '').toLowerCase();
    const whenToUse = (skill['when_to_use'] || '').toLowerCase();
    const combined = desc + ' ' + whenToUse;

    const missingCompanions = companions.filter(c => {
      if (typeof c !== 'object' || !c.id) return false;
      const idWords = c.id.replace(/-/g, ' ').toLowerCase();
      return !combined.includes(idWords) && !combined.includes(c.id.toLowerCase());
    });

    if (missingCompanions.length === 0) continue;

    hasSuggestions = true;
    output += `## ${skill.name}\n`;
    output += `Current description: ${skill.description || '(none)'}\n`;
    output += `Current when_to_use: ${skill['when_to_use'] || '(none)'}\n`;
    output += `Missing from description: ${missingCompanions.map(c => `${c.id} (${c.type})`).join(', ')}\n`;

    // Generate suggestion
    const companionMentions = missingCompanions.map(c => {
      if (c.type === 'browser-server') return `Includes browser-based ${c.id.replace(/-/g, ' ')}`;
      if (c.type === 'mcp-server') return `Enhanced by ${c.id} MCP`;
      return `Produces ${c.id.replace(/-/g, ' ')}`;
    }).join('. ');

    const existingWhen = skill['when_to_use'] || '';
    const suggested = existingWhen
      ? `${existingWhen} ${companionMentions}.`
      : `${companionMentions}.`;
    output += `Suggested when_to_use: "${suggested}"\n\n`;
  }

  if (!hasSuggestions) {
    output += '(No suggestions — all companions are mentioned in descriptions.)\n';
  }

  return output;
}

// --- Using-Skills In-Place Update ---

function updateUsingSkills(routingTable) {
  const USING_SKILLS_PATH = path.join(SKILLS_DIR, 'using-skills', 'SKILL.md');
  if (!fs.existsSync(USING_SKILLS_PATH)) {
    console.warn('WARN: skills/using-skills/SKILL.md not found, skipping in-place update');
    return;
  }

  const content = fs.readFileSync(USING_SKILLS_PATH, 'utf-8');
  const BEGIN_MARKER = '<!-- BEGIN GENERATED ROUTING TABLE -->';
  const END_MARKER = '<!-- END GENERATED ROUTING TABLE -->';

  const beginIdx = content.indexOf(BEGIN_MARKER);
  const endIdx = content.indexOf(END_MARKER);

  if (beginIdx === -1 || endIdx === -1) {
    console.warn('WARN: Marker comments not found in using-skills/SKILL.md, skipping in-place update');
    console.warn('  Add these markers to enable auto-update:');
    console.warn(`  ${BEGIN_MARKER}`);
    console.warn(`  ${END_MARKER}`);
    return;
  }

  const before = content.substring(0, beginIdx + BEGIN_MARKER.length);
  const after = content.substring(endIdx);
  const updated = before + '\n' + routingTable + '\n' + after;

  fs.writeFileSync(USING_SKILLS_PATH, updated);
}

// --- Main ---

function main() {
  console.log('Generating capability index...\n');

  // Discover and parse skills
  const skills = discoverSkills();
  console.log(`Found ${skills.length} skills\n`);

  // Validate
  const { errors, warnings } = validate(skills);

  for (const warn of warnings) {
    console.warn(`WARN: ${warn}`);
  }

  if (errors.length > 0) {
    console.error('\nERRORS:');
    for (const err of errors) {
      console.error(`  ERROR: ${err}`);
    }
    console.error(`\n${errors.length} error(s) found. Fix them before proceeding.`);
    process.exit(1);
  }

  // Create generated directory
  if (!fs.existsSync(GENERATED_DIR)) {
    fs.mkdirSync(GENERATED_DIR, { recursive: true });
  }

  // Generate outputs
  const sessionStart = generateSessionStartCapabilities(skills);
  const routingTable = generateRoutingTable(skills);
  const whenToUse = generateWhenToUseSuggestions(skills);

  fs.writeFileSync(path.join(GENERATED_DIR, 'session-start-capabilities.md'), sessionStart);
  fs.writeFileSync(path.join(GENERATED_DIR, 'routing-table.md'), routingTable);
  fs.writeFileSync(path.join(GENERATED_DIR, 'when-to-use-suggestions.md'), whenToUse);

  // Update using-skills/SKILL.md in-place between marker comments
  updateUsingSkills(routingTable);

  console.log(`\nGenerated:`);
  console.log(`  generated/session-start-capabilities.md`);
  console.log(`  generated/routing-table.md`);
  console.log(`  generated/when-to-use-suggestions.md`);
  console.log(`  skills/using-skills/SKILL.md (routing table section updated)`);

  if (warnings.length > 0) {
    console.log(`\n${warnings.length} warning(s) — review above.`);
  }

  console.log('\nDone.');
}

main();

#!/usr/bin/env node

/**
 * generate-routing-graph.js
 *
 * Reads frontmatter from all skills, agents, and the superthink command,
 * then generates an interactive Cytoscape.js graph with dagre hierarchical layout:
 *   - /superthink as root entry node at top
 *   - Skills arranged in phase-ranked layers (define → plan → build → verify → review → ship)
 *   - Agents as diamond-shaped nodes
 *   - Companion tools as small attached badges
 *   - Five edge types: chain, superthink, auto-trigger, conditional, dispatches
 *
 * Libraries: cytoscape.js + dagre + cytoscape-dagre (bundled inline for offline use)
 * Output: generated/routing-graph.html (standalone, open in browser)
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..', 'plugins', 'super-agent-skills');
const SKILLS_DIR = path.join(ROOT, 'skills');
const AGENTS_DIR = path.join(ROOT, 'agents');
const COMMANDS_DIR = path.join(ROOT, 'commands');
const GENERATED_DIR = path.join(ROOT, 'generated');

// --- Minimal YAML parser (same approach as generate-capability-index.js) ---

const CUSTOM_FIELDS = ['phase', 'produces', 'requires', 'companions', 'chainsTo', 'chainsFrom', 'autoTriggers'];
const PASSTHROUGH_FIELDS = ['name', 'description', 'when_to_use'];

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
    if (!line.trim() || line.trim().startsWith('#')) { i++; continue; }
    const kvMatch = line.match(/^(\w[\w-]*)\s*:\s*(.+)$/);
    if (kvMatch) {
      const key = kvMatch[1];
      let value = kvMatch[2].trim();
      if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'")))
        value = value.slice(1, -1);
      if (value.startsWith('[') && value.endsWith(']'))
        value = value.slice(1, -1).split(',').map(s => s.trim().replace(/^["']|["']$/g, ''));
      result[key] = value;
      i++; continue;
    }
    const blockMatch = line.match(/^(\w[\w-]*)\s*:\s*$/);
    if (blockMatch) {
      const key = blockMatch[1];
      i++;
      if (!CUSTOM_FIELDS.includes(key) && !PASSTHROUGH_FIELDS.includes(key)) {
        while (i < lines.length && (lines[i].startsWith(' ') || lines[i].startsWith('\t') || !lines[i].trim())) i++;
        continue;
      }
      const blockResult = parseBlock(lines, i);
      result[key] = blockResult.value;
      i = blockResult.nextIndex;
      continue;
    }
    i++;
  }
  return result;
}

function parseBlock(lines, startIndex) {
  const items = [];
  let i = startIndex;
  while (i < lines.length) {
    const line = lines[i];
    if (line.trim() && !line.startsWith(' ') && !line.match(/^\s*-/)) break;
    if (!line.trim()) { i++; continue; }
    const arrayItemMatch = line.match(/^(\s*)-\s+(.+)$/);
    if (arrayItemMatch) {
      const itemIndent = arrayItemMatch[1].length;
      let value = arrayItemMatch[2].trim();
      if (!value.includes(':') || value.startsWith('"') || value.startsWith("'")) {
        items.push(value.replace(/^["']|["']$/g, ''));
        i++; continue;
      }
      const objMatch = value.match(/^(\w[\w-]*)\s*:\s*(.+)$/);
      if (objMatch) {
        const obj = {};
        obj[objMatch[1]] = cleanValue(objMatch[2]);
        i++;
        while (i < lines.length) {
          const nextLine = lines[i];
          if (!nextLine.trim()) { i++; continue; }
          if (nextLine.match(new RegExp(`^\\s{${itemIndent}}-`))) break;
          if (!nextLine.startsWith(' '.repeat(itemIndent + 2))) break;
          const fieldMatch = nextLine.trim().match(/^(\w[\w-]*)\s*:\s*(.+)$/);
          if (fieldMatch) obj[fieldMatch[1]] = cleanValue(fieldMatch[2]);
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
  if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'")))
    val = val.slice(1, -1);
  if (val === 'true') return true;
  if (val === 'false') return false;
  return val;
}

function toArray(val) {
  if (!val) return [];
  if (Array.isArray(val)) return val;
  return [val];
}

// --- Discover all entities ---

function discoverSkills() {
  const skills = [];
  for (const entry of fs.readdirSync(SKILLS_DIR, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    const p = path.join(SKILLS_DIR, entry.name, 'SKILL.md');
    if (!fs.existsSync(p)) continue;
    const fm = parseFrontmatter(fs.readFileSync(p, 'utf-8'));
    if (fm) skills.push(fm);
  }
  return skills;
}

function discoverAgents() {
  const agents = [];
  if (!fs.existsSync(AGENTS_DIR)) return agents;
  for (const f of fs.readdirSync(AGENTS_DIR)) {
    if (!f.endsWith('.md')) continue;
    const fm = parseFrontmatter(fs.readFileSync(path.join(AGENTS_DIR, f), 'utf-8'));
    if (fm && fm.name) agents.push(fm);
  }
  return agents;
}

function getSuperthinkRoutes() {
  const p = path.join(COMMANDS_DIR, 'superthink.md');
  if (!fs.existsSync(p)) return [];
  const content = fs.readFileSync(p, 'utf-8');
  const routes = [];
  // Extract skill references from the superthink command
  const matches = content.matchAll(/super-agent-skills:(\S+)/g);
  const seen = new Set();
  for (const m of matches) {
    const name = m[1].replace(/`/g, '');
    if (!seen.has(name)) { seen.add(name); routes.push(name); }
  }
  return routes;
}

// Which skills does subagent-driven-development auto-trigger?
function getSubagentAutoTriggers() {
  const p = path.join(SKILLS_DIR, 'subagent-driven-development', 'SKILL.md');
  if (!fs.existsSync(p)) return [];
  const content = fs.readFileSync(p, 'utf-8');
  const triggers = [];
  const seen = new Set();
  // Look for invoke lines in the domain skills auto-trigger section
  const regex = /invoke\s+`super-agent-skills:([^`]+)`/gi;
  for (const m of content.matchAll(regex)) {
    if (!seen.has(m[1])) { seen.add(m[1]); triggers.push(m[1]); }
  }
  return triggers;
}

// Brainstorming conditionally invokes threat-modeling
function getBrainstormingConditionals() {
  const p = path.join(SKILLS_DIR, 'brainstorming', 'SKILL.md');
  if (!fs.existsSync(p)) return [];
  const content = fs.readFileSync(p, 'utf-8');
  if (content.includes('super-agent-skills:threat-modeling')) return ['threat-modeling'];
  return [];
}

// Which agents does requesting-code-review use?
function getReviewAgents() {
  // The code-reviewer and related agents are used by the review skill
  return ['code-reviewer', 'architecture-reviewer', 'security-auditor'];
}

// Which agents does test-driven-development reference?
function getTDDAgents() {
  return ['test-engineer', 'test-generator'];
}

function getDependencyAgents() {
  return ['dependency-auditor'];
}

function getMigrationAgents() {
  return ['migration-assistant'];
}

// --- Build graph ---

function buildGraph(skills, agents) {
  const nodes = [];
  const links = [];
  const nodeMap = new Map();

  const PHASE_COLORS = {
    define:  '#9b59b6',
    plan:    '#3498db',
    build:   '#2ecc71',
    verify:  '#1abc9c',
    review:  '#f39c12',
    ship:    '#e74c3c',
    support: '#95a5a6',
    meta:    '#bdc3c7',
  };

  // /superthink root node
  nodes.push({ id: '/superthink', type: 'entry', phase: 'entry', label: '/superthink', companions: [] });
  nodeMap.set('/superthink', true);

  // Skills
  for (const skill of skills) {
    const companions = toArray(skill.companions)
      .filter(c => typeof c === 'object')
      .map(c => ({ id: c.id, type: c.type, description: c.description || '' }));

    nodes.push({
      id: skill.name,
      type: 'skill',
      phase: skill.phase || 'unknown',
      label: skill.name,
      companions,
      produces: toArray(skill.produces),
      autoTriggers: toArray(skill.autoTriggers),
    });
    nodeMap.set(skill.name, true);
  }

  // Agents
  for (const agent of agents) {
    nodes.push({
      id: agent.name,
      type: 'agent',
      phase: 'agent',
      label: agent.name,
      companions: [],
      description: agent.description || '',
    });
    nodeMap.set(agent.name, true);
  }

  // --- Edges ---

  // 1. /superthink → direct routes (from chainsFrom: superthink in frontmatter)
  for (const skill of skills) {
    const from = toArray(skill.chainsFrom);
    if (from.includes('superthink')) {
      links.push({ source: '/superthink', target: skill.name, type: 'superthink', label: '' });
    }
  }

  // 2. chainsTo edges (main chain workflow)
  for (const skill of skills) {
    for (const target of toArray(skill.chainsTo)) {
      if (nodeMap.has(target)) {
        links.push({ source: skill.name, target, type: 'chain', label: '' });
      }
    }
  }

  // 3. Subagent auto-trigger domain skills
  const subagentTriggers = getSubagentAutoTriggers();
  for (const target of subagentTriggers) {
    if (nodeMap.has(target) && target !== 'subagent-driven-development') {
      links.push({ source: 'subagent-driven-development', target, type: 'auto-trigger', label: 'auto' });
    }
  }

  // 4. Brainstorming → threat-modeling (conditional)
  for (const target of getBrainstormingConditionals()) {
    if (nodeMap.has(target)) {
      links.push({ source: 'brainstorming', target, type: 'conditional', label: 'if security-sensitive' });
    }
  }

  // 5. Skills → Agents
  for (const agentName of getReviewAgents()) {
    if (nodeMap.has(agentName)) {
      links.push({ source: 'requesting-code-review', target: agentName, type: 'dispatches', label: '' });
    }
  }
  for (const agentName of getTDDAgents()) {
    if (nodeMap.has(agentName)) {
      links.push({ source: 'test-driven-development', target: agentName, type: 'dispatches', label: '' });
    }
  }
  for (const agentName of getDependencyAgents()) {
    if (nodeMap.has(agentName)) {
      links.push({ source: 'security-and-hardening', target: agentName, type: 'dispatches', label: '' });
    }
  }
  for (const agentName of getMigrationAgents()) {
    if (nodeMap.has(agentName)) {
      // migration-assistant is standalone, reachable from superthink
      links.push({ source: '/superthink', target: agentName, type: 'superthink', label: '' });
    }
  }

  // Deduplicate links
  const linkSet = new Set();
  const uniqueLinks = links.filter(l => {
    const key = `${l.source}→${l.target}→${l.type}`;
    if (linkSet.has(key)) return false;
    linkSet.add(key);
    return true;
  });

  return { nodes, links: uniqueLinks, phaseColors: PHASE_COLORS };
}

// --- Library loading ---

const LIBS = [
  { name: 'cytoscape.min.js', url: 'https://unpkg.com/cytoscape@3.33.2/dist/cytoscape.min.js' },
  { name: 'dagre.min.js', url: 'https://unpkg.com/dagre@0.8.5/dist/dagre.min.js' },
  { name: 'cytoscape-dagre.js', url: 'https://unpkg.com/cytoscape-dagre@2.5.0/cytoscape-dagre.js' },
];

function loadLib(lib) {
  const cachePath = path.join(ROOT, 'node_modules', '.cache', lib.name);
  const tmpPath = path.join('/tmp', lib.name);
  for (const p of [cachePath, tmpPath]) {
    if (fs.existsSync(p)) return fs.readFileSync(p, 'utf-8');
  }
  try {
    const { execSync } = require('child_process');
    fs.mkdirSync(path.dirname(cachePath), { recursive: true });
    execSync('curl -sL "' + lib.url + '" -o "' + cachePath + '"', { timeout: 30000 });
    return fs.readFileSync(cachePath, 'utf-8');
  } catch (e) {
    console.warn('WARN: Could not download ' + lib.name);
    return null;
  }
}

// --- Generate HTML ---

function generateHTML(graph) {

  // Graph data is injected as JSON (safe — no backticks in JSON.stringify output)
  const graphJSON = JSON.stringify(graph);

  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>super-agent-skills Routing Graph</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { background: #1a1a2e; color: #e0e0e0; font-family: 'Inter', -apple-system, sans-serif; overflow: hidden; }

  #graph { position: absolute; top: 0; left: 0; width: 100vw; height: 100vh; }

  #controls {
    position: fixed; top: 16px; left: 16px; z-index: 10;
    background: rgba(30, 30, 60, 0.95); border-radius: 8px; padding: 16px;
    border: 1px solid rgba(255,255,255,0.1); max-width: 280px;
  }
  #controls h1 { font-size: 14px; margin-bottom: 8px; color: #fff; }
  #controls .subtitle { font-size: 11px; color: #888; margin-bottom: 12px; }

  .legend { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 8px; }
  .legend-item { display: flex; align-items: center; gap: 4px; font-size: 10px; }
  .legend-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
  .legend-diamond { width: 10px; height: 10px; transform: rotate(45deg); flex-shrink: 0; }
  .legend-square { width: 10px; height: 10px; border-radius: 2px; flex-shrink: 0; }

  .edge-legend { margin-top: 8px; border-top: 1px solid rgba(255,255,255,0.1); padding-top: 8px; }
  .edge-legend-item { display: flex; align-items: center; gap: 6px; font-size: 10px; margin-bottom: 4px; }
  .edge-sample { width: 30px; height: 0; display: inline-block; flex-shrink: 0; }

  #tooltip {
    position: fixed; display: none; background: rgba(20, 20, 50, 0.97);
    border: 1px solid rgba(255,255,255,0.2); border-radius: 6px; padding: 10px 14px;
    font-size: 12px; max-width: 320px; pointer-events: none; z-index: 20;
    box-shadow: 0 4px 20px rgba(0,0,0,0.5);
  }
</style>
</head>
<body>

<div id="controls">
  <h1>super-agent-skills</h1>
  <div class="subtitle">Routing Graph &mdash; /superthink entry point</div>

  <div class="legend">
    <div class="legend-item"><div class="legend-dot" style="background:#f5a623;border:2px solid #fff;"></div> Entry</div>
    <div class="legend-item"><div class="legend-dot" style="background:#9b59b6"></div> define</div>
    <div class="legend-item"><div class="legend-dot" style="background:#3498db"></div> plan</div>
    <div class="legend-item"><div class="legend-dot" style="background:#2ecc71"></div> build</div>
    <div class="legend-item"><div class="legend-dot" style="background:#1abc9c"></div> verify</div>
    <div class="legend-item"><div class="legend-dot" style="background:#f39c12"></div> review</div>
    <div class="legend-item"><div class="legend-dot" style="background:#e74c3c"></div> ship</div>
    <div class="legend-item"><div class="legend-dot" style="background:#95a5a6"></div> support</div>
    <div class="legend-item"><div class="legend-dot" style="background:#bdc3c7"></div> meta</div>
    <div class="legend-item"><div class="legend-diamond" style="background:#6c5ce7"></div> agent</div>
    <div class="legend-item"><div class="legend-square" style="background:#7ecfff"></div> companion</div>
  </div>

  <div class="edge-legend">
    <div class="edge-legend-item"><span class="edge-sample" style="border-top:2px solid rgba(255,255,255,0.4);"></span> chain</div>
    <div class="edge-legend-item"><span class="edge-sample" style="border-top:2px dashed rgba(255,200,50,0.5);"></span> /superthink</div>
    <div class="edge-legend-item"><span class="edge-sample" style="border-top:2px dashed rgba(100,220,100,0.4);"></span> auto-trigger</div>
    <div class="edge-legend-item"><span class="edge-sample" style="border-top:2px dashed rgba(220,100,100,0.4);"></span> conditional</div>
    <div class="edge-legend-item"><span class="edge-sample" style="border-top:2px dotted rgba(150,150,255,0.3);"></span> dispatches</div>
  </div>
</div>

<div id="tooltip"></div>
<div id="graph"></div>

<!-- LIBS_PLACEHOLDER -->
<script>
try {

var graphData = JSON.parse('${graphJSON.replace(/\\/g, '\\\\').replace(/'/g, "\\'")}');

var PHASE_COLORS = graphData.phaseColors;
PHASE_COLORS.entry = '#f5a623';
PHASE_COLORS.agent = '#6c5ce7';
PHASE_COLORS.companion = '#7ecfff';
PHASE_COLORS.unknown = '#555';

// --- Build Cytoscape elements ---
var elements = [];

// Nodes
graphData.nodes.forEach(function(n) {
  var size = n.id === '/superthink' ? 50 : n.type === 'agent' ? 25 : 35;
  elements.push({
    group: 'nodes',
    data: {
      id: n.id,
      label: n.label,
      type: n.type,
      phase: n.phase,
      color: PHASE_COLORS[n.phase] || '#555',
      companions: n.companions || [],
      produces: n.produces || [],
      autoTriggers: n.autoTriggers || [],
      description: n.description || '',
      size: size,
    }
  });

  // Companion tool nodes
  if (n.companions && n.companions.length > 0) {
    n.companions.forEach(function(c) {
      var compId = n.id + ':' + c.id;
      elements.push({
        group: 'nodes',
        data: {
          id: compId,
          label: c.id,
          type: 'companion',
          phase: 'companion',
          color: c.type === 'browser-server' ? '#7ecfff' : '#7effaa',
          size: 18,
          companions: [], produces: [], autoTriggers: [],
          description: c.description || '',
        }
      });
      elements.push({
        group: 'edges',
        data: {
          id: 'comp-' + compId,
          source: n.id,
          target: compId,
          type: 'companion',
          label: '',
        }
      });
    });
  }
});

// Edges
graphData.links.forEach(function(l, i) {
  elements.push({
    group: 'edges',
    data: {
      id: 'e' + i,
      source: l.source,
      target: l.target,
      type: l.type,
      label: l.label || '',
    }
  });
});

// --- Cytoscape stylesheet ---
var style = [
  {
    selector: 'node',
    style: {
      'background-color': 'data(color)',
      'label': 'data(label)',
      'color': '#fff',
      'text-valign': 'bottom',
      'text-halign': 'center',
      'text-margin-y': 6,
      'font-size': 9,
      'font-weight': 500,
      'width': 'data(size)',
      'height': 'data(size)',
      'border-width': 1,
      'border-color': 'rgba(255,255,255,0.3)',
      'text-wrap': 'wrap',
      'text-max-width': 110,
      'text-outline-color': '#1a1a2e',
      'text-outline-width': 2,
    }
  },
  {
    selector: 'node[type = "agent"]',
    style: {
      'shape': 'diamond',
    }
  },
  {
    selector: 'node[type = "companion"]',
    style: {
      'shape': 'round-rectangle',
      'font-size': 7,
      'border-color': 'rgba(126,207,255,0.6)',
    }
  },
  {
    selector: 'node[id = "/superthink"]',
    style: {
      'border-width': 3,
      'border-color': '#fff',
      'font-size': 12,
      'font-weight': 700,
    }
  },
  // Edge styles
  {
    selector: 'edge',
    style: {
      'curve-style': 'bezier',
      'target-arrow-shape': 'triangle',
      'arrow-scale': 0.8,
      'width': 1.5,
    }
  },
  {
    selector: 'edge[type = "chain"]',
    style: {
      'line-color': 'rgba(255,255,255,0.4)',
      'target-arrow-color': 'rgba(255,255,255,0.5)',
      'width': 2,
    }
  },
  {
    selector: 'edge[type = "superthink"]',
    style: {
      'line-color': 'rgba(255,200,50,0.5)',
      'target-arrow-color': 'rgba(255,200,50,0.7)',
      'line-style': 'dashed',
      'line-dash-pattern': [6, 3],
      'width': 2,
    }
  },
  {
    selector: 'edge[type = "auto-trigger"]',
    style: {
      'line-color': 'rgba(100,220,100,0.4)',
      'target-arrow-color': 'rgba(100,220,100,0.5)',
      'line-style': 'dashed',
      'line-dash-pattern': [3, 3],
    }
  },
  {
    selector: 'edge[type = "conditional"]',
    style: {
      'line-color': 'rgba(220,100,100,0.4)',
      'target-arrow-color': 'rgba(220,100,100,0.5)',
      'line-style': 'dashed',
      'line-dash-pattern': [8, 3, 2, 3],
      'label': 'data(label)',
      'font-size': 7,
      'text-rotation': 'autorotate',
      'color': 'rgba(220,100,100,0.8)',
      'text-outline-color': '#1a1a2e',
      'text-outline-width': 1,
    }
  },
  {
    selector: 'edge[type = "dispatches"]',
    style: {
      'line-color': 'rgba(150,150,255,0.3)',
      'target-arrow-color': 'rgba(150,150,255,0.4)',
      'line-style': 'dotted',
    }
  },
  {
    selector: 'edge[type = "companion"]',
    style: {
      'line-color': 'rgba(126,207,255,0.3)',
      'target-arrow-shape': 'none',
      'line-style': 'dotted',
      'width': 1,
    }
  },
  // Dimmed state for click-to-highlight
  {
    selector: '.dimmed',
    style: { 'opacity': 0.12 }
  },
  {
    selector: '.highlighted',
    style: { 'opacity': 1 }
  },
];

// --- Register dagre layout and initialize Cytoscape ---
cytoscape.use(cytoscapeDagre);

var cy = cytoscape({
  container: document.getElementById('graph'),
  elements: elements,
  style: style,
  layout: {
    name: 'dagre',
    rankDir: 'TB',
    rankSep: 70,
    nodeSep: 30,
    edgeSep: 15,
    padding: 50,
    animate: false,
  },
  minZoom: 0.1,
  maxZoom: 5,
  wheelSensitivity: 0.3,
});

// Fit to viewport after layout
cy.fit(undefined, 50);

// --- Tooltip ---
var tooltip = document.getElementById('tooltip');

cy.on('mouseover', 'node', function(e) {
  var d = e.target.data();
  tooltip.style.display = 'block';
  var html = '<div style="font-weight:700;font-size:13px;margin-bottom:4px;">' + d.label + '</div>';
  html += '<div style="font-size:11px;color:#aaa;">' +
    (d.type === 'agent' ? 'Agent' : d.type === 'companion' ? 'Companion Tool' : 'Phase: ' + (d.phase || '?')) + '</div>';

  if (d.companions && d.companions.length > 0) {
    html += '<div style="margin-top:6px;font-size:11px;"><strong>Companions:</strong> ' +
      d.companions.map(function(c) { return '<span style="color:#7ecfff;">' + c.id + '</span> (' + c.type + ')'; }).join(', ') +
      '</div>';
  }
  if (d.produces && d.produces.length > 0) {
    html += '<div style="margin-top:4px;font-size:11px;color:#999;">Produces: ' + d.produces.join(', ') + '</div>';
  }
  if (d.autoTriggers && d.autoTriggers.length > 0) {
    html += '<div style="margin-top:4px;font-size:11px;color:#f0c040;">Auto-triggers: ' + d.autoTriggers.join('; ') + '</div>';
  }
  if (d.description && d.type !== 'companion') {
    html += '<div style="margin-top:4px;font-size:11px;color:#999;">' + d.description + '</div>';
  }
  tooltip.innerHTML = html;
});

cy.on('mousemove', 'node', function(e) {
  tooltip.style.left = (e.originalEvent.clientX + 15) + 'px';
  tooltip.style.top = (e.originalEvent.clientY - 10) + 'px';
});

cy.on('mouseout', 'node', function() {
  tooltip.style.display = 'none';
});

// --- Click to highlight neighborhood ---
cy.on('tap', 'node', function(e) {
  var node = e.target;
  var neighborhood = node.closedNeighborhood();
  cy.elements().addClass('dimmed').removeClass('highlighted');
  neighborhood.removeClass('dimmed').addClass('highlighted');
});

cy.on('tap', function(e) {
  if (e.target === cy) {
    cy.elements().removeClass('dimmed').removeClass('highlighted');
  }
});

} catch(err) {
  document.body.innerHTML = '<div style="color:#f66;padding:40px;font-family:monospace;white-space:pre-wrap;">'
    + '<h2>Graph rendering error</h2>' + (err.stack || err.message || err) + '</div>';
}
</script>
</body>
</html>`;
}

// --- Main ---

function main() {
  console.log('Generating routing graph...\n');

  const skills = discoverSkills();
  const agents = discoverAgents();

  console.log('Found ' + skills.length + ' skills, ' + agents.length + ' agents\n');

  const graph = buildGraph(skills, agents);

  console.log('Graph: ' + graph.nodes.length + ' nodes, ' + graph.links.length + ' edges\n');

  if (!fs.existsSync(GENERATED_DIR)) {
    fs.mkdirSync(GENERATED_DIR, { recursive: true });
  }

  let html = generateHTML(graph);

  // Inject libraries via split+join (not .replace()) because minified
  // sources contain $& and $' patterns that .replace() interprets as
  // special replacement tokens, garbling the output.
  const libSources = LIBS.map(lib => loadLib(lib));
  const allLibs = libSources.filter(Boolean);
  if (allLibs.length < LIBS.length) {
    console.error('ERROR: Could not load all libraries. Aborting.');
    process.exit(1);
  }
  const libTag = '<script>' + allLibs.join(';\n') + '<\/script>';
  const placeholder = '<!-- LIBS_PLACEHOLDER -->';
  const parts = html.split(placeholder);
  html = parts[0] + libTag + parts.slice(1).join(placeholder);

  const outPath = path.join(GENERATED_DIR, 'routing-graph.html');
  fs.writeFileSync(outPath, html);

  console.log('Generated: ' + outPath);
  console.log('Open in a browser to view the interactive graph.');
}

main();

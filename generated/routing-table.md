## Skills by Phase

### define
| Skill | Produces | Companions |
|-------|----------|------------|
| brainstorming | design-spec, acceptance-tests | visual-companion (browser-server) |
| threat-modeling | threat-model | — |

### plan
| Skill | Produces | Companions |
|-------|----------|------------|
| writing-plans | implementation-plan | — |

### build
| Skill | Produces | Companions |
|-------|----------|------------|
| api-and-interface-design | api-design, type-contracts | — |
| compound-engineering | multi-stream-code | — |
| context-engineering | optimized-context | — |
| documentation-and-adrs | documentation, adrs | — |
| frontend-ui-engineering | ui-components | — |
| incremental-implementation | working-code | — |
| performance-optimization | optimized-code | — |
| security-and-hardening | hardened-code | — |
| source-driven-development | doc-verified-code | context7 (mcp-server) |
| subagent-driven-development | working-code | — |
| test-driven-development | tested-code | — |

### verify
| Skill | Produces | Companions |
|-------|----------|------------|
| browser-testing-with-devtools | visual-verification, dom-state, console-logs, network-traces | chrome-devtools (mcp-server) |
| systematic-debugging | root-cause-analysis | — |
| verification-before-completion | verification-evidence | — |

### review
| Skill | Produces | Companions |
|-------|----------|------------|
| code-simplification | simplified-code | — |
| receiving-code-review | reviewed-changes | — |
| requesting-code-review | review-report | — |

### ship
| Skill | Produces | Companions |
|-------|----------|------------|
| finishing-a-development-branch | merged-code | — |
| wrap-up | checkpoint | — |

### support
| Skill | Produces | Companions |
|-------|----------|------------|
| dispatching-parallel-agents | parallel-results | — |
| executing-plans | executed-plan | — |
| using-git-worktrees | isolated-workspace | — |
| writing-skills | validated-skill | — |

### meta
| Skill | Produces | Companions |
|-------|----------|------------|
| plugin-audit | audit-report | — |
| project-setup | claude-md | — |
| using-skills | routing-guidance | — |

## Workflow Chains

```
brainstorming → writing-plans → subagent-driven-development → requesting-code-review → [wrap-up | finishing-a-development-branch]
systematic-debugging → test-driven-development → verification-before-completion
compound-engineering → writing-plans (per stream) → subagent-driven-development → requesting-code-review
executing-plans → requesting-code-review → [wrap-up | finishing-a-development-branch]
```

## /superthink Entry Points

| Intent | Routes To |
|--------|----------|
| (see /superthink) | brainstorming |
| (see /superthink) | code-simplification |
| (see /superthink) | context-engineering |
| (see /superthink) | finishing-a-development-branch |
| (see /superthink) | requesting-code-review |
| (see /superthink) | systematic-debugging |
| (see /superthink) | test-driven-development |
| (see /superthink) | writing-plans |

## Auto-Triggers During Implementation

| Context Detected | Invoke |
|-----------------|--------|
| task touches API endpoints | api-and-interface-design |
| task defines module boundaries | api-and-interface-design |
| task creates REST or GraphQL endpoints | api-and-interface-design |
| browser debugging needed | browser-testing-with-devtools |
| visual verification of UI required | browser-testing-with-devtools |
| architecture decision needed | documentation-and-adrs |
| public API change | documentation-and-adrs |
| task modifies UI components | frontend-ui-engineering |
| task creates frontend pages or layouts | frontend-ui-engineering |
| task has performance requirements | performance-optimization |
| performance regression detected | performance-optimization |
| task handles user input or authentication | security-and-hardening |
| task handles external data or integrations | security-and-hardening |
| task uses framework-specific APIs | source-driven-development |


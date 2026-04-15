## Skills by Phase

### define
| Skill | Produces | Companions |
|-------|----------|------------|
| brainstorming | design-spec, acceptance-tests | visual-companion (browser-server) |

### plan
| Skill | Produces | Companions |
|-------|----------|------------|
| writing-plans | implementation-plan | — |

### build
| Skill | Produces | Companions |
|-------|----------|------------|
| subagent-driven-development | working-code | — |

### review
| Skill | Produces | Companions |
|-------|----------|------------|
| requesting-code-review | review-report | — |

### ship
| Skill | Produces | Companions |
|-------|----------|------------|
| finishing-a-development-branch | merged-code | — |
| wrap-up | checkpoint | — |

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
| (see /superthink) | finishing-a-development-branch |
| (see /superthink) | requesting-code-review |
| (see /superthink) | writing-plans |


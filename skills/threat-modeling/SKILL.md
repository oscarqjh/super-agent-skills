---
name: threat-modeling
description: Proactive security design using STRIDE methodology. Use when building features that handle authentication, user input, external APIs, payment, PII, or multi-tenant access. Identifies threats before implementation so mitigations are designed in, not bolted on.
---

# Threat Modeling

Identify security threats BEFORE implementation using STRIDE methodology. This is proactive security — find threats at design time when mitigations are cheap, not at review time when they're expensive.

**Use this when:** the feature involves authentication, user input, external APIs, payment processing, PII, multi-tenant access, or any data flow that crosses trust boundaries.

**Use `super-agent-skills:security-and-hardening` instead when:** you're implementing and need reactive security checks (input validation, output encoding, etc.).

**These skills complement each other:** threat-modeling identifies WHAT to protect against (design time), security-and-hardening ensures the protection is correctly IMPLEMENTED (build time).

**Announce at start:** "I'm using threat-modeling to identify security threats before implementation."

## When to Use

- Building authentication or authorization features
- Handling user input that flows to databases, APIs, or other systems
- Integrating with external APIs or third-party services
- Processing payments or sensitive financial data
- Storing or transmitting PII (personally identifiable information)
- Building multi-tenant features (data isolation between users/orgs)
- Adding webhooks, callbacks, or any external-facing endpoints

**When NOT to use:**
- Static content pages with no data flow
- Internal tools with no authentication
- Pure UI styling changes
- Documentation updates

## STRIDE Framework

For each component or data flow in the feature, systematically check:

| Threat | Question | Examples |
|--------|----------|---------|
| **S**poofing | Can someone pretend to be another user/system? | Forged JWT, session hijacking, IP spoofing, stolen API keys |
| **T**ampering | Can someone modify data they shouldn't? | SQL injection, request body manipulation, unsigned webhooks, MITM attacks |
| **R**epudiation | Can someone deny performing an action? | Missing audit logs, unsigned transactions, no request logging |
| **I**nformation Disclosure | Can someone access data they shouldn't? | Exposed API keys, verbose error messages, directory traversal, IDOR |
| **D**enial of Service | Can someone make the system unavailable? | Unbounded queries, resource exhaustion, regex DoS, missing rate limits |
| **E**levation of Privilege | Can someone gain permissions they shouldn't? | IDOR, missing auth checks, role confusion, JWT claim manipulation |

## The Process

### Step 1: Scope

Define what you're threat modeling:
- Which feature or component?
- What data does it handle?
- Who are the users (and potential attackers)?

### Step 2: Diagram Data Flows

Map the system's data flows, identifying trust boundaries:

```
┌─────────────────────────────────────────────────┐
│ TRUST BOUNDARY: Public Internet                  │
│                                                  │
│  [User Browser] ──HTTP──→ [Load Balancer]        │
│                                                  │
├─────────────────────────────────────────────────┤
│ TRUST BOUNDARY: DMZ                              │
│                                                  │
│  [Load Balancer] ──→ [API Server]                │
│                                                  │
├─────────────────────────────────────────────────┤
│ TRUST BOUNDARY: Internal Network                 │
│                                                  │
│  [API Server] ──→ [Database]                     │
│  [API Server] ──→ [External Payment API]         │
│  [API Server] ──→ [Email Service]                │
│                                                  │
└─────────────────────────────────────────────────┘
```

Every arrow crossing a trust boundary is a potential attack surface.

### Step 3: Apply STRIDE

For each component and each data flow crossing a trust boundary, check all 6 STRIDE categories:

```markdown
### Component: API Server — POST /api/tasks

| STRIDE | Threat? | Detail | Severity |
|--------|---------|--------|----------|
| Spoofing | Yes | No auth check — anyone can create tasks | High |
| Tampering | Yes | Request body not validated — SQL injection risk | Critical |
| Repudiation | No | API logs all requests with user ID | - |
| Info Disclosure | Yes | Error messages expose stack trace | Medium |
| DoS | Yes | No rate limiting on endpoint | Medium |
| Elevation | Yes | No check that user belongs to the org | High |
```

### Step 4: Prioritize

Rate each identified threat:

| Likelihood × Impact | Priority |
|---------------------|----------|
| High × High | Critical — must mitigate before shipping |
| High × Medium or Medium × High | High — mitigate before shipping |
| Medium × Medium | Medium — mitigate if feasible |
| Low × any or any × Low | Low — accept risk or defer |

### Step 5: Define Mitigations

For each High/Critical threat, define a specific countermeasure:

```markdown
| Threat | Mitigation | Implementation |
|--------|-----------|----------------|
| No auth on POST /api/tasks | Add JWT validation middleware | Use existing authMiddleware from auth.ts |
| SQL injection in request body | Parameterized queries + Zod validation | Add TaskCreateSchema, apply at route level |
| Stack trace in errors | Sanitize error responses | Use existing ErrorHandler, disable stack in prod |
| No rate limiting | Add rate limiter middleware | Use express-rate-limit, 100 req/min per IP |
| Missing org membership check | Add org authorization check | Query org_members table before allowing action |
```

### Step 6: Add to Spec

Append the threat model as a new section in the design spec:

```markdown
## Threat Model

### Scope
[Feature being modeled]

### Threats Identified
[STRIDE table from Step 3]

### Mitigations
[Table from Step 5]

### Accepted Risks
[Low-priority threats that won't be mitigated, with justification]
```

These mitigations become acceptance criteria — the implementer must address them during build, and the reviewer must verify them during code review.

## Output Format

The threat model document should contain:
1. Scope and data flow diagram
2. STRIDE analysis per component
3. Prioritized threat list
4. Mitigation plan for High/Critical threats
5. Accepted risks for Low/Medium threats

## Anti-Rationalizations

| Thought | Reality |
|---------|---------|
| "We'll add security later" | Security bolted on after implementation is 10x more expensive than security designed in. |
| "This feature isn't security-sensitive" | If it handles user data, auth, or external input, it's security-sensitive. Most features are. |
| "STRIDE is overkill" | STRIDE takes 15 minutes for a simple feature. Finding a vulnerability in production takes days. |
| "Our framework handles security" | Frameworks handle common cases. Your specific data flows, business logic, and integration points need specific analysis. |
| "We have security-and-hardening for this" | security-and-hardening catches implementation bugs. Threat modeling catches design flaws. You need both. |

## Red Flags

- Building auth features without a threat model
- External-facing endpoints with no STRIDE analysis
- "Accepted risks" that are actually High severity (accepting what should be mitigated)
- Threat model that only covers Spoofing and Tampering (STRIDE has 6 categories — check all of them)
- No data flow diagram — you can't identify threats you can't see

## Verification

After threat modeling:

- [ ] Data flow diagram exists showing trust boundaries
- [ ] STRIDE applied to every component crossing a trust boundary
- [ ] Every High/Critical threat has a specific mitigation
- [ ] Mitigations added as acceptance criteria in the spec
- [ ] Accepted risks are documented with justification
- [ ] security-and-hardening skill referenced for implementation phase

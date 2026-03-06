# Context Card Schema

**Version:** 1.0
**Status:** Active
**Principles implemented:** P7, P12
**Dependencies:**
  Pattern Library Schema v1.0
  Context Curation Policy v1.0
  Naming Conventions v0.1
**Last Updated:** 2026-03-04

---

## Purpose

This schema defines two things:

1. **`ContextCard`** — what `get_context_card` delivers to an agent.
   Minimum sufficient context. Task-facing. No governance metadata.

2. **`ContextCardMetadata`** — what is stored in the `documents` table
   alongside the card. Governance-facing. Never delivered to the agent.

The split is load-bearing. Governance metadata in an agent's context
window is noise. It consumes attention without improving output. The
agent needs to know what to do and how to do it — not what zone it is
in or who generated its card.

---

## ContextCard — Agent-Facing

This is the complete, typed definition of what an agent receives when
it calls `get_context_card`.

```typescript
type ContextCard = {

  // ── Task Brief ─────────────────────────────────────────────
  // What the agent is here to do.
  // Plain English. One paragraph maximum.
  // For ROLE cards (no specific task): describes the agent's
  // standing brief across all tasks of its class.
  task_brief:       string

  task_id:          string | null   // 'task-07' | null for ROLE cards
  feature_id:       string | null   // 'feat-003' | null if no feature scope

  // ── Certainty Threshold ────────────────────────────────────
  // Declared in the agent class definition.
  // Delivered here so the agent has it before its first action.
  // If the agent's confidence in its output falls below this
  // value it must call raise_uncertainty before proceeding.
  certainty_threshold: number       // 0.0–1.0

  // ── Tools Guidance ─────────────────────────────────────────
  // Plain English map of which tool to call for what.
  // Mirrors the agent's tool list, not a tutorial.
  // Purpose: eliminate tool choice confusion without adding docs.
  tools_guidance:   ToolGuidance[]

  // ── Patterns ───────────────────────────────────────────────
  // Validated patterns relevant to this agent + task.
  // ORCHESTRATOR / OWNER: max 7
  // EXECUTOR / REVIEWER subagents: max 3
  // Ordered by nv_score DESC — highest confidence first.
  patterns:         PatternEntry[]

  // ── Anti-Patterns ──────────────────────────────────────────
  // Confirmed failure modes for this agent class and task domain.
  // Always surfaced separately — never buried in patterns list.
  // For subagents: only entries tagged for this specific class.
  anti_patterns:    PatternEntry[]

  // ── Constraints ────────────────────────────────────────────
  // Distilled from policies — the actionable rule, not the
  // policy reference.
  // For subagents: only constraints relevant to this agent's
  // specific output. Not the parent orchestrator's full set.
  constraints:      string[]

  // ── Open Flags ─────────────────────────────────────────────
  // Conflicts, known gaps, uncertainties, exclusions.
  // Field is OMITTED (not empty array) if no flags exist.
  // An agent that sees open flags must address them before
  // proceeding, or call raise_uncertainty if it cannot.
  open_flags?:      OpenFlag[]
}

// ── Supporting Types ─────────────────────────────────────────

type ToolGuidance = {
  tool_name:        string    // exact MCP tool name as registered
  use_for:          string    // one sentence, plain English
                              // "Read your task specification"
                              // "Submit your completed proof when done"
                              // "Call this if you are blocked or uncertain"
}

type PatternEntry = {
  pattern_id:       string    // 'pat-004'
  pattern_name:     string
  current_nv:       number    // NV score at time of card generation
  summary:          string    // max 3 sentences — full detail in KB
  relevance_reason: string    // why this pattern was selected for
                              // this specific agent + task combination
}

type OpenFlag = {
  flag_type:        'CONFLICT' | 'GAP' | 'KNOWN_UNCERTAINTY' | 'EXCLUSION'
  description:      string    // plain English, actionable
  source:           string    // actor or system component that raised it
                              // e.g. 'context-curator', 'system:nexus',
                              //      'framework-owner'
}
```

---

## ContextCardMetadata — Governance-Facing

Stored in the `documents` table. Returned only by `read_context_card`
(available to FrameworkOwner and ContextCurator, not to task agents).
Never delivered to the agent via `get_context_card`.

```typescript
type ContextCardMetadata = {
  // Identity
  agent_class:      string    // 'task-performer'
  agent_instance:   string    // 'task-performer:task-07'
  card_type:        'ROLE' | 'TASK' | 'SUBAGENT'
  card_version:     string    // 'v3' — increments on each regeneration
  card_hash:        string    // SHA-256 of serialised ContextCard content

  // Provenance
  generated_at:     string    // ISO 8601 UTC
  generated_by:     string    // always 'context-curator'
  valid_until:      string | null

  // Staleness
  stale:            boolean
  stale_reason:     string | null

  // Governance (not in card, available for FOA audit)
  zone:             string    // 'zone-4', 'zone-5'
  source_pattern_ids: string[]  // patterns selected during composition
  source_policy_ids:  string[]  // policies consulted during composition

  // Traceability
  source_audit_id:  number    // audit_log.id of get_context_card call
}
```

---

## Example Cards

### TASK card — TaskPerformer for task-07

```json
{
  "task_brief": "Implement the login form validation for feat-003. The form must validate email format, password minimum length (8 characters), and display inline field errors. Do not implement authentication — that is out of scope for this task.",
  "task_id": "task-07",
  "feature_id": "feat-003",
  "certainty_threshold": 0.8,
  "tools_guidance": [
    {
      "tool_name": "get_context_card",
      "use_for": "Load this brief at the start of your session"
    },
    {
      "tool_name": "read_task_spec_task_07",
      "use_for": "Read your full task specification and acceptance criteria"
    },
    {
      "tool_name": "append_work_log_task_07",
      "use_for": "Log significant steps, decisions, and blockers as you work"
    },
    {
      "tool_name": "submit_proof_task_07",
      "use_for": "Submit your completed proof of completion when done"
    },
    {
      "tool_name": "search_knowledge_base",
      "use_for": "Search for relevant patterns or prior solutions"
    },
    {
      "tool_name": "raise_uncertainty",
      "use_for": "Call this immediately if you are blocked or uncertain"
    }
  ],
  "patterns": [
    {
      "pattern_id": "pat-004",
      "pattern_name": "Inline Field Validation",
      "current_nv": 9,
      "summary": "Validate on blur, not on submit. Display errors adjacent to the field, not in a summary block. Clear errors as soon as the field value becomes valid.",
      "relevance_reason": "This task requires inline field error display per task spec."
    },
    {
      "pattern_id": "pat-007",
      "pattern_name": "Email Format Validation",
      "current_nv": 6,
      "summary": "Use the HTML5 email input type as the first validation layer. Add a regex check for cases where browser validation is bypassed. Do not validate MX records client-side.",
      "relevance_reason": "Task-07 requires email format validation specifically."
    }
  ],
  "anti_patterns": [
    {
      "pattern_id": "pat-012",
      "pattern_name": "Submit-Time Validation Only",
      "current_nv": 0,
      "summary": "Validating only on form submit forces users to correct all errors at once. This pattern has produced poor UX scores on three prior tasks.",
      "relevance_reason": "Direct failure mode for the inline validation requirement in this task."
    }
  ],
  "constraints": [
    "Use React Hook Form — do not implement custom form state management",
    "Target Node 20 LTS",
    "Branch must be task/task-07",
    "Do not implement authentication — it is out of scope for task-07"
  ]
}
```

### SUBAGENT card — ProofReviewer for task-07

Note the narrower scope — 1 pattern, 1 anti-pattern, 3 constraints,
and tools guidance for only the tools this subagent holds.

```json
{
  "task_brief": "Review the submitted proof for task-07 against the proof template. Return PASS with specific evidence, or FAIL with the exact unmet criteria. Do not evaluate implementation quality — only whether the proof satisfies the template.",
  "task_id": "task-07",
  "feature_id": "feat-003",
  "certainty_threshold": 0.9,
  "tools_guidance": [
    {
      "tool_name": "get_context_card",
      "use_for": "Load this brief before reviewing"
    },
    {
      "tool_name": "read_proof_template_task_07",
      "use_for": "Read the proof template — this defines what a passing proof must contain"
    },
    {
      "tool_name": "read_proof_task_07",
      "use_for": "Read the submitted proof to review"
    },
    {
      "tool_name": "raise_uncertainty",
      "use_for": "Call this if the proof or template is ambiguous or incomplete"
    }
  ],
  "patterns": [
    {
      "pattern_id": "pat-019",
      "pattern_name": "Evidence-First Proof Review",
      "current_nv": 7,
      "summary": "Check for explicit evidence against each template criterion before forming a verdict. A proof that asserts completion without linking to evidence fails. Match evidence to criteria one-to-one.",
      "relevance_reason": "Primary review pattern for all proof template validation."
    }
  ],
  "anti_patterns": [
    {
      "pattern_id": "pat-023",
      "pattern_name": "Implementation Quality Scope Creep",
      "current_nv": 0,
      "summary": "Reviewing implementation quality, code style, or architectural decisions during proof review is out of scope and delays task progression. ProofReviewer evaluates the proof document only.",
      "relevance_reason": "Common failure mode for proof reviewers — stay within scope."
    }
  ],
  "constraints": [
    "Review the proof document only — do not fetch or evaluate source code",
    "Your output is PASS or FAIL with evidence — no other verdicts are valid",
    "If the template has unfilled sections, that is a FAIL"
  ]
}
```

---

## What Is Never in a Context Card

| Excluded item | Reason |
|---|---|
| File paths | Agent does not need to know where things live — tools handle location |
| Policy document references | Agent receives distilled rules, not references to read |
| Skill content | Delivered by VS Code host layer independently — see H-SKILLS-01 |
| Governance metadata | Zone, card version, generated_at — for FOA and DB only |
| `active_policies` list | A reference is not a constraint — distil the rule |
| All available patterns | Minimum sufficient, not maximum available |
| Parent orchestrator's full constraint set | Subagents receive only constraints relevant to their output |

---

## Version History

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-03-04 | Initial schema. `permissions` block removed (pre-MCP model). Governance metadata split into ContextCardMetadata. `tools_guidance` replaces file path lists. `active_policies` removed. SUBAGENT card type added with 3-pattern cap. Skills exclusion rule formalised (H-SKILLS-01). |

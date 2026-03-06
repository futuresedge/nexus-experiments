# Context Curation Policy

**Version:** 1.0
**Status:** Active
**Principles implemented:** P7, P8, P12
**Dependencies:**
  Pattern Library Schema v1.0
  Context Card Schema v1.0
  Tool Grammar v0.3
  Naming Conventions v0.1
**Last Updated:** 2026-03-04

---

## Purpose

This policy governs how the ContextCurator builds, delivers, and
invalidates context cards. It exists because context is not free.
Every item in an agent's context card consumes attention window — the
agent's finite working memory. A poorly composed card does not just
add noise; it actively degrades the agent's performance by diluting
the signal it needs to act.

**The governing principle (P7):**
Give agents the minimum sufficient context to do their job well. Not
the minimum possible context. Not all available context. Minimum
sufficient. The ContextCurator's job is to make that judgment call
well, every time.

---

## Card Types

| Type | Recipient | Trigger | Scope |
|---|---|---|---|
| `ROLE` | An agent class at startup | Agent instantiation | General role patterns only |
| `TASK` | An agent performing a task | Task published to zone | Task-specific patterns + constraints |
| `SUBAGENT` | A subagent with a micro-task | Subagent activated | Narrowly scoped to micro-task only |

Role cards are never task-specific. Task cards are never reused across
tasks. Subagent cards are the most restricted — they contain only what
the subagent needs to complete its single defined responsibility.

---

## Composition Rules

### Step 1 — Retrieve task and agent metadata

Fetch:
- Agent class name and agent type (ORCHESTRATOR / EXECUTOR /
  REVIEWER / OWNER)
- Task ID, task domain tags, task feature ID
- Any open uncertainties for this task
- Any open flags from prior cards for this task

### Step 2 — Select patterns

Query the Pattern Library using composition rules from Pattern Library
Schema v1.0:
- Status = `ACTIVE`
- Tags match task domain
- `agent_classes` includes this agent's kebab-case class name
- `agent_types` includes this agent's type or `"*"`
- Apply cap: 7 patterns for orchestrators/owners, 3 for subagents
- Order by `nv_score DESC` — highest confidence first
- Run conflict detection before finalising selection

### Step 3 — Distil constraints

Retrieve relevant policies for this task type and agent class.
Extract the actionable constraints as plain English rules:

```
✅  "Use npm, not bun"
✅  "Target Node 20 LTS"
✅  "Branch must be task/task-07"
✅  "Do not modify migration files once committed"

❌  "See .framework/policies/dependency-policy.md for rules"
    (a reference is not a constraint — distil the rule)
```

The agent receives the rule, not the reference. Policy document
paths are not delivered in the card.

For subagents: include only constraints directly relevant to this
agent's output. The parent orchestrator's full constraint set is
not passed down.

### Step 4 — Compose tools guidance

For each tool in the agent's tool list, write a one-line statement
of purpose in plain English:

```
get_context_card          → "Load your task brief before starting"
read_task_spec_task_07    → "Read your full task specification"
append_work_log_task_07   → "Log significant steps as you work"
submit_proof_task_07      → "Submit your completed proof when done"
raise_uncertainty         → "Call this if you are blocked or uncertain"
```

This is not a tutorial. It is a quick-reference map so the agent
knows which tool to reach for without consulting any other document.

### Step 5 — Collect open flags

Retrieve:
- Any CONFLICT detected in Step 2
- Any GAP identified in prior task cards
- Any KNOWN_UNCERTAINTY from the uncertainty log for this task
- Any EXCLUSION applied during pattern selection (why a pattern was
  excluded that might otherwise have been expected)

If no flags: omit the field entirely. Do not deliver an empty flags
block — it signals to the agent that it should look for flags,
consuming attention on a null result.

### Step 6 — Set certainty threshold

Retrieve the declared `certainty_threshold` from the agent class
definition. Deliver it directly in the card. The agent should never
need to look this up — it must be present before the agent takes its
first action.

### Step 7 — Compute card hash

SHA-256 of the complete serialised card content. Store this hash in
`ContextCardMetadata` (the DB record, not the card itself). Used for:
- Stale detection (has the card changed since the agent last loaded it?)
- Chain of custody (what exactly did this agent receive?)

### Step 8 — Store and deliver

Store: `ContextCard + ContextCardMetadata` in the `documents` table.
Deliver: `ContextCard` only via `get_context_card`.

The metadata stays in the database. The agent receives only the card.

---

## Staleness Rules

A context card becomes stale when any of its source material changes.
The ContextCurator must regenerate the card before the agent's next
task if any of the following have changed since the card was generated:

| Source change | Stale? |
|---|---|
| Task spec updated | ✅ Yes — full regeneration |
| Pattern NV score updated | 🟡 Conditional — only if the score crosses a selection threshold |
| New pattern promoted to ACTIVE with matching tags | ✅ Yes — may change selection |
| Constraint-governing policy updated | ✅ Yes — distilled constraints may change |
| Agent class definition updated | ✅ Yes — tools guidance and certainty threshold may change |
| Stream event written (no spec change) | ❌ No — stream events do not affect card content |

**Stale card behaviour:**
A stale card is not automatically regenerated — regeneration is
triggered by the ContextCurator on task state transition. An agent
that calls `get_context_card` while the card is marked stale receives
the existing card with an `OPEN_FLAG` of type `KNOWN_UNCERTAINTY`:

```json
{
  "flag_type": "KNOWN_UNCERTAINTY",
  "description": "This card may be stale. Task spec was updated after this card was generated.",
  "source": "system:nexus"
}
```

The agent must call `raise_uncertainty` if it cannot proceed safely
with a potentially stale card.

---

## Skills Are Not Delivered by This Policy

Skills (`.github/skills/*.skill.md`) are delivered by the VS Code host
layer at agent instantiation. They are not part of the context card.

**Never include skill content in a context card.** Skills represent
role knowledge — how the agent does its job. Context cards represent
task knowledge — what this specific task requires. These are different
things delivered by different mechanisms.

Duplicating skill content in the card:
- Wastes the agent's attention budget
- Creates a maintenance sync problem (skill and card can diverge)
- Signals that the skill is not trusted to be delivered correctly
  by VS Code — which undermines the architecture

If skill content seems necessary in the card, the correct action is
to review whether the skill is correctly scoped and referenced in the
agent class definition, not to copy it into the card.

---

## What the ContextCurator Must Never Do

- Include file paths in the card (no document paths, no policy paths,
  no skill paths) — the agent does not need to know where things live
- Include governance metadata in the card (no zone, no card version,
  no generated_at) — this is for the FOA and the DB record only
- Include patterns with status ≠ ACTIVE
- Include more than 7 patterns for orchestrators or 3 for subagents
- Pass the parent orchestrator's full constraint set to a subagent
- Regenerate a card mid-task without updating the `source_audit_id`
  chain in the audit log
- Deliver a card with unresolved CONFLICT flags without flagging them
  explicitly in `open_flags`

---

## Version History

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-03-04 | Initial policy. Subagent card type added. Skills explicitly excluded from cards. Governance metadata split defined. Staleness rules formalised. |
# Pattern Library Schema

**Version:** 1.0
**Status:** Active
**Principles implemented:** P7, P11, P12
**Dependencies:** Tool Grammar v0.3, Naming Conventions v0.1
**Last Updated:** 2026-03-04

---

## Purpose

The Pattern Library is the framework's institutional memory. It records
validated solutions, tested approaches, and confirmed failure modes so
agents do not rediscover them from scratch on every task.

It exists to serve one narrow purpose: **to give an agent the minimum
sufficient context to do its job well, without giving it everything
the framework has ever learned.**

The pattern library is not a documentation archive. Entries that are not
actively improving agent output have no place in it.

---

## Entry Lifecycle

```
CANDIDATE                 ACTIVE                   RETIRED
(newly recorded)  ──→    (promoted by FW Owner)  ──→  (superseded)
                                ↑
                    NV score reaches threshold
                    and FrameworkOwner approves
```

**NV score (Negative Validation score):**
Counts how many times a pattern has been applied and the outcome was
not negative. It is not a quality score — it is a confidence score.
A pattern with NV = 12 has been applied twelve times without producing
a known failure. It has not necessarily produced twelve successes;
absence of failure and presence of success are different claims.

**Promotion threshold:** NV ≥ 5 AND FrameworkOwner approval.
**Retirement trigger:** Pattern superseded by a newer entry, or NV
accumulates negative evidence on review (recorded via `pattern_evidence`
table).

---

## Schema Definition

```sql
CREATE TABLE patterns (
  -- Identity
  id                TEXT PRIMARY KEY,         -- 'pat-001', 'pat-004'
  pattern_name      TEXT NOT NULL,            -- human-readable name
  status            TEXT NOT NULL             -- 'CANDIDATE' | 'ACTIVE' | 'RETIRED'
                    DEFAULT 'CANDIDATE',
  
  -- Classification
  tags              TEXT NOT NULL,            -- JSON array: ["validation", "zone-4", "forms"]
  agent_classes     TEXT NOT NULL,            -- JSON array of kebab-case agent class names
                                              -- ["task-performer", "qa-executor"]
  agent_types       TEXT NOT NULL             -- JSON array: ["EXECUTOR", "REVIEWER", "*"]
                    DEFAULT '["*"]',          -- "*" = all types in the listed agent_classes
  
  -- Content
  summary           TEXT NOT NULL,            -- max 3 sentences
  detail            TEXT NOT NULL,            -- full pattern description (Markdown)
  anti_pattern      TEXT,                     -- what NOT to do (optional but recommended)
  example           TEXT,                     -- concrete example (optional)
  
  -- Confidence
  nv_score          INTEGER NOT NULL          -- Negative Validation score
                    DEFAULT 0,
  source_session    TEXT NOT NULL,            -- session or experiment where first recorded
  
  -- Provenance
  created_at        TEXT NOT NULL,            -- ISO 8601 UTC
  updated_at        TEXT NOT NULL,
  promoted_at       TEXT,                     -- null until ACTIVE
  promoted_by       TEXT,                     -- 'framework-owner' always
  superseded_by     TEXT                      -- pat-xxx if RETIRED
);

CREATE TABLE pattern_evidence (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  pattern_id        TEXT NOT NULL,
  task_id           TEXT NOT NULL,
  outcome           TEXT NOT NULL,            -- 'POSITIVE' | 'NEGATIVE' | 'NEUTRAL'
  notes             TEXT,
  recorded_at       TEXT NOT NULL,
  recorded_by       TEXT NOT NULL,            -- actor value from audit log
  
  FOREIGN KEY (pattern_id) REFERENCES patterns(id)
);

CREATE INDEX idx_patterns_status ON patterns(status);
CREATE INDEX idx_patterns_tags ON patterns(tags);
CREATE INDEX idx_evidence_pattern ON pattern_evidence(pattern_id);
CREATE INDEX idx_evidence_task ON pattern_evidence(task_id);
```

---

## The `agent_types` Field

This field was added to support the subagent model, where a
`TaskOrchestrator` and a `TaskPerformer` are different agent types
with different context needs. A pattern relevant to a coordinator may
not be relevant to a subagent reviewer and vice versa.

**Valid values:**

| Value | Meaning |
|---|---|
| `"ORCHESTRATOR"` | Pattern applies to orchestrator agents only |
| `"EXECUTOR"` | Pattern applies to executor subagents only |
| `"REVIEWER"` | Pattern applies to reviewer subagents only |
| `"OWNER"` | Pattern applies to owner agents only |
| `"*"` | Pattern applies to all agent types in `agent_classes` |

**Example:**
A pattern for "how to delegate parallel QA reviews effectively" is
relevant to `TaskOrchestrator` but not to the `ProofReviewer` subagents
it delegates to:

```json
{
  "agent_classes": ["task-orchestrator"],
  "agent_types": ["ORCHESTRATOR"]
}
```

A pattern for "how to write a proof of completion" is relevant only
to executor subagents performing the task:

```json
{
  "agent_classes": ["task-performer"],
  "agent_types": ["EXECUTOR"]
}
```

A validation rubric pattern is relevant to all reviewer subagents
regardless of specific class:

```json
{
  "agent_classes": ["proof-reviewer", "ac-reviewer", "environment-reviewer"],
  "agent_types": ["REVIEWER"]
}
```

---

## Composition Rules for Context Cards

When the ContextCurator builds a context card for an agent, it selects
patterns from this table according to the following rules:

**Orchestrator and Owner agents:**
- Status must be `ACTIVE`
- Tags must match the task domain
- `agent_classes` must include this agent's kebab class name
- `agent_types` must include `"ORCHESTRATOR"`, `"OWNER"`, or `"*"`
- Maximum 7 patterns per card
- Anti-patterns: include all relevant entries (no cap)

**Executor and Reviewer subagents:**
- Same status and tag matching rules as above
- `agent_types` must include `"EXECUTOR"`, `"REVIEWER"`, or `"*"`
- Maximum **3 patterns per card** — subagent context windows must
  stay narrow; they have one job
- Anti-patterns: include only entries tagged for this specific
  agent class
- Constraints: include only constraints directly relevant to this
  agent's output, not the parent orchestrator's full constraint set

**Conflict detection:**
Before composing a card, the ContextCurator must check whether any
selected pattern is contradicted by another selected pattern on any
dimension (approach, order, scope). If a conflict is found, it must:
1. Select the higher-NV-score pattern
2. Exclude the lower-NV-score pattern
3. Record an `OPEN_FLAG` with `flag_type = 'CONFLICT'` in the card

---

## Canonical Queries

### QP1 — Active patterns for a given agent class and domain

```sql
SELECT
  id, pattern_name, nv_score, summary, anti_pattern
FROM patterns
WHERE status = 'ACTIVE'
  AND agent_classes LIKE '%task-performer%'
  AND tags LIKE '%validation%'
ORDER BY nv_score DESC
LIMIT 7;
```

### QP2 — Pattern evidence for a given task

```sql
SELECT
  p.pattern_name,
  pe.outcome,
  pe.notes,
  pe.recorded_at
FROM pattern_evidence pe
JOIN patterns p ON pe.pattern_id = p.id
WHERE pe.task_id = 'task-07'
ORDER BY pe.recorded_at ASC;
```

### QP3 — Candidate patterns ready for promotion review

```sql
SELECT
  id, pattern_name, nv_score, source_session, created_at
FROM patterns
WHERE status = 'CANDIDATE'
  AND nv_score >= 5
ORDER BY nv_score DESC;
```

### QP4 — Negative evidence accumulation (retirement candidates)

```sql
SELECT
  p.id,
  p.pattern_name,
  COUNT(CASE WHEN pe.outcome = 'NEGATIVE' THEN 1 END) AS negative_count,
  COUNT(CASE WHEN pe.outcome = 'POSITIVE' THEN 1 END) AS positive_count
FROM patterns p
JOIN pattern_evidence pe ON p.id = pe.pattern_id
WHERE p.status = 'ACTIVE'
GROUP BY p.id
HAVING negative_count >= 2
ORDER BY negative_count DESC;
```

---

## Integrity Rules

**Rule 1 — Immutable IDs**
Pattern IDs are never reused. A retired pattern keeps its ID. The
`superseded_by` field links retired entries to their replacement.

**Rule 2 — Summary length**
The `summary` field must be ≤ 3 sentences. This is enforced at write
time. The summary is delivered to agents in context cards; longer
summaries consume attention budget without proportional value.

**Rule 3 — Promotion authority**
Only `framework-owner` may set `status = 'ACTIVE'`. The `promoted_by`
field must be `'framework-owner'`. This is enforced in the Nexus server
tool implementation for `write_patterns`.

**Rule 4 — Evidence before promotion**
A pattern may not be promoted to ACTIVE without at least one
`pattern_evidence` row with `outcome = 'POSITIVE'` and NV ≥ 5.
The promotion tool must validate this before accepting the write.

---

## Version History

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-03-04 | Initial schema. `agent_types` field added for subagent model. Composition rules split by agent type. Naming conventions applied. |
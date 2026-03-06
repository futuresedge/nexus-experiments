# Audit Log Schema

**Version:** 1.0
**Status:** Active
**Principles implemented:** P5, P12
**Dependencies:** Tool Grammar v0.3, Naming Conventions v0.1
**Last Updated:** 2026-03-04

---

## Purpose

This schema defines the structure and query interface for the `audit_log`
table — the complete, immutable record of every action taken by every agent
in the framework.

The audit log exists to answer one question with absolute reliability:
**"What happened, when, and why?"** Every row is write-once. No row is ever
modified or deleted after creation. The log grows monotonically.

This is not a debugging tool or a performance monitoring system. It is a
causal reconstruction engine. When a task produces unexpected output, the
audit log makes the chain of decisions that led to that output traceable
by a human with no prior knowledge of the agent system.

---

## Schema Definition

```sql
CREATE TABLE audit_log (
  -- Identity
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp         TEXT NOT NULL,              -- ISO 8601 UTC
  
  -- Actor
  actor             TEXT NOT NULL,              -- {agent-class}:{task-id} or system:{component}
  actor_type        TEXT NOT NULL,              -- 'agent' | 'human' | 'webhook' | 'system'
  
  -- Tool and scope
  tool_name         TEXT NOT NULL,              -- exact MCP tool name (from grammar)
  task_id           TEXT,                       -- null for universal/role-scoped tools
  
  -- Payload (query and result data)
  query             TEXT,                       -- for search_ tools
  tags              TEXT,                       -- JSON array, for search_ tools with filters
  result_count      INTEGER,                    -- for search_ tools
  top_entry_ids     TEXT,                       -- JSON array, for search_ tools
  
  reason            TEXT,                       -- for write_, submit_ tools (mandatory)
  
  doc_version_hash  TEXT,                       -- for read_, write_ tools on versioned documents
  entry_hash        TEXT,                       -- for append_ tools (covers appended entry only)
  entry_preview     TEXT,                       -- first 80 chars of appended entry (human readability)
  
  resource_version  TEXT,                       -- for get_ tools (e.g. context card v3)
  resource_hash     TEXT,                       -- for get_ tools
  
  -- State transition evidence (for submit_, raise_, request_)
  prior_state       TEXT,                       -- state before transition
  new_state         TEXT,                       -- state after transition
  
  -- Traceability
  source_audit_id   INTEGER,                    -- references id — links this action to prior action
  
  FOREIGN KEY (source_audit_id) REFERENCES audit_log(id)
);

CREATE INDEX idx_audit_task ON audit_log(task_id, timestamp);
CREATE INDEX idx_audit_actor ON audit_log(actor, timestamp);
CREATE INDEX idx_audit_tool ON audit_log(tool_name, timestamp);
CREATE INDEX idx_audit_timestamp ON audit_log(timestamp);
```

---

## Field Definitions

### Identity Fields

**`id`**
Auto-incrementing integer. Primary key. The monotonic sequence itself
is load-bearing — a gap in IDs signals a database integrity issue.

**`timestamp`**
ISO 8601 UTC format. Example: `2026-03-04T13:22:45.123Z`
Server-written, never supplied by the caller. Nanosecond precision not
required — milliseconds sufficient for causal ordering within a task.

### Actor Fields

**`actor`**
The entity that invoked the tool. Format defined by naming conventions:

| Actor type | Format | Example |
|---|---|---|
| Agent (task-scoped) | `{agent-class}:{task-id}` | `task-performer:task-07` |
| Agent (role-scoped) | `{agent-class}` | `framework-owner` |
| Human | `human:{role}` | `human:approver` |
| Webhook | `webhook:{source}` | `webhook:github` |
| System | `system:{component}` | `system:nexus` |

Agent class names in the `actor` field use kebab-case derived from the
PascalCase class name:
```
TaskPerformer   → task-performer
ContextCurator  → context-curator
QAExecutor      → qa-executor
```

**`actor_type`**
Enum: `'agent'`, `'human'`, `'webhook'`, `'system'`
Derivable from `actor` by prefix, but stored explicitly for query
performance. The audit log is queried more often than it is written —
a denormalized field that eliminates a string split in every query is
a correct tradeoff.

### Tool and Scope Fields

**`tool_name`**
The exact MCP tool name as registered in the Nexus server. Must conform
to the tool grammar. Examples: `read_task_spec_task_07`,
`submit_proof_task_07`, `get_context_card`, `raise_uncertainty`.

**`task_id`**
The task identifier if this action is task-scoped, else `NULL`.
For universal tools (`get_context_card`, `raise_uncertainty`), this
field is `NULL`. For task-scoped tools, it is extracted from the tool
name suffix:
```
read_task_spec_task_07  → task_id = 'task-07'
submit_proof_task_12    → task_id = 'task-12'
```

This field enables the canonical query Q1: "Show me everything that
happened during task-07."

### Payload Fields (Query and Result Data)

These fields capture the inputs and outputs of tools that perform
queries or searches. They are nullable — only populated for tools where
they are semantically meaningful.

**`query`**
The search query string for `search_` tools. Free text.
Example: `"login form validation patterns"`

**`tags`**
JSON array of tag filters applied to the search. Example:
`["zone-4", "validation"]`

**`result_count`**
Integer count of results returned by a `search_` tool. Example: `3`

**`top_entry_ids`**
JSON array of the top N entry IDs returned by a `search_` tool.
Example: `["pat-001", "pat-002", "pat-003"]`

These four fields together answer the question: **"What did the agent
search for, and what did it find?"** This is causally significant. If
an agent produces a poor implementation on a task type that has a known
Pattern Library entry, the audit log will show whether the agent
searched for that pattern before implementing, and whether the pattern
appeared in the search results.

**`reason`**
Mandatory for `write_` and `submit_` tools. Free text explanation of
why the document was written or updated. The Zod schema must enforce
this — it cannot be optional or empty string. Example:
`"Updated to include Redis dependency"`

**`doc_version_hash`**
SHA-256 hash of the document content for `read_` and `write_` tools.
Records which version of the document the agent read or wrote.

The version hash answers a different question than the document version
number. The version number records "what did the document contain"; the
hash in the audit log records "what specific content did this agent see
at this timestamp." Both are necessary for chain of custody.

**`entry_hash`**
SHA-256 hash of the appended entry for `append_` tools. Covers the
appended entry only, not the entire document. This makes individual
entries independently traceable.

**`entry_preview`**
First 80 characters of the appended entry, for human readability in
audit log queries. The full entry is stored in the document itself;
this preview makes the audit log self-describing without requiring a
join to the documents table.

**`resource_version`**
Version identifier for `get_` tools. Example: `"v3"` for a context
card on its third regeneration.

**`resource_hash`**
SHA-256 hash of the resource content for `get_` tools.

### State Transition Evidence

**`prior_state`**
The state of the task or entity immediately before this action.
Populated only for tools that cause state transitions (`submit_`,
`request_`, `raise_`).

**`new_state`**
The state of the task or entity immediately after this action.
Populated only for tools that cause state transitions.

The pair (`prior_state`, `new_state`) makes state transitions
auditable without consulting the `tasks` table. The audit log becomes
self-contained for causal reconstruction.

### Traceability Fields

**`source_audit_id`**
Foreign key to `audit_log(id)`. Links this action to a prior action
that caused it or provided its input.

Example chain:
```
Row 101: task-performer:task-07 calls read_task_spec_task_07
Row 102: task-performer:task-07 calls search_knowledge_base
         source_audit_id = 101 (searched after reading spec)
Row 103: task-performer:task-07 calls submit_proof_task_07
         source_audit_id = 102 (proof informed by search results)
```

This field enables reconstruction of **why** an agent made a decision,
not just **what** it did. It is nullable — the first action in a task
has no prior source.

---

## Canonical Queries

These eight queries define the audit log's interface. If the schema
cannot answer these queries efficiently, it is incomplete.

### Q1 — Task Timeline

**Question:** What actions were taken during task-07, in order?

```sql
SELECT
  timestamp,
  actor,
  tool_name,
  reason,
  new_state
FROM audit_log
WHERE task_id = 'task-07'
ORDER BY timestamp ASC;
```

**Purpose:** Reconstruct the complete sequence of events for a single
task. This is the primary diagnostic query when a task produces
unexpected output.

---

### Q2 — Decision Context

**Question:** What was the agent reading immediately before it submitted
its proof for task-07?

```sql
SELECT
  timestamp,
  tool_name,
  doc_version_hash,
  query,
  result_count
FROM audit_log
WHERE actor = 'task-performer:task-07'
  AND tool_name LIKE 'read_%' OR tool_name LIKE 'search_%'
  AND timestamp < (
    SELECT timestamp
    FROM audit_log
    WHERE actor = 'task-performer:task-07'
      AND tool_name = 'submit_proof_task_07'
    LIMIT 1
  )
ORDER BY timestamp DESC;
```

**Purpose:** Understand what information the agent had access to when
it made a decision. Critical for determining whether a failure was due
to missing patterns, incorrect patterns, or correct patterns that the
agent did not apply.

---

### Q3 — Pattern Usage

**Question:** Did any agent search for pattern `pat-004` in the last 7 days?

```sql
SELECT
  timestamp,
  actor,
  query,
  result_count,
  top_entry_ids
FROM audit_log
WHERE tool_name = 'search_knowledge_base'
  AND top_entry_ids LIKE '%pat-004%'
  AND timestamp > datetime('now', '-7 days')
ORDER BY timestamp DESC;
```

**Purpose:** Validate that promoted patterns are actually being
discovered by agents. If a pattern exists but never appears in search
results, either the pattern's tags are wrong or agents are not
searching for relevant terms.

---

### Q4 — State Transition History

**Question:** How many times has task-07 transitioned state, and what
were the transitions?

```sql
SELECT
  timestamp,
  actor,
  tool_name,
  prior_state,
  new_state
FROM audit_log
WHERE task_id = 'task-07'
  AND new_state IS NOT NULL
ORDER BY timestamp ASC;
```

**Purpose:** Verify the task followed its expected lifecycle. Detect
loops (e.g., task moved to QA three times before passing). Identify
where rework occurred.

---

### Q5 — Actor Activity Summary

**Question:** What did QAExecutor do across all tasks yesterday?

```sql
SELECT
  task_id,
  tool_name,
  COUNT(*) as call_count
FROM audit_log
WHERE actor LIKE 'qa-executor:%'
  AND DATE(timestamp) = DATE('now', '-1 day')
GROUP BY task_id, tool_name
ORDER BY task_id, call_count DESC;
```

**Purpose:** Understand agent workload distribution. Identify tasks
where an agent made an unusually high number of tool calls (may signal
confusion or a poorly-specified task).

---

### Q6 — Uncertainty Timeline

**Question:** Show all uncertainty raises in chronological order.

```sql
SELECT
  timestamp,
  actor,
  task_id,
  reason,
  new_state
FROM audit_log
WHERE tool_name = 'raise_uncertainty'
ORDER BY timestamp DESC;
```

**Purpose:** Track framework gaps. Each `raise_uncertainty` call
represents a condition the framework could not handle autonomously.
Recurring uncertainty patterns indicate missing policies or ambiguous
specifications.

---

### Q7 — Human Intervention Points

**Question:** When did HumanApprover act, and what triggered each action?

```sql
SELECT
  a.timestamp,
  a.tool_name,
  a.task_id,
  a.reason,
  prior.tool_name AS prior_action,
  prior.actor AS prior_actor
FROM audit_log a
LEFT JOIN audit_log prior ON a.source_audit_id = prior.id
WHERE a.actor_type = 'human'
ORDER BY a.timestamp DESC;
```

**Purpose:** Identify where human judgment was required. High frequency
of human intervention on a particular task type signals that task type
needs better automation or clearer specifications.

---

### Q8 — Chain of Custody

**Question:** Trace the chain of actions from task spec read to proof
submission for task-07.

```sql
WITH RECURSIVE trace AS (
  SELECT
    id,
    timestamp,
    actor,
    tool_name,
    source_audit_id,
    0 AS depth
  FROM audit_log
  WHERE tool_name = 'submit_proof_task_07'
  
  UNION ALL
  
  SELECT
    a.id,
    a.timestamp,
    a.actor,
    a.tool_name,
    a.source_audit_id,
    t.depth + 1
  FROM audit_log a
  JOIN trace t ON a.id = t.source_audit_id
)
SELECT
  depth,
  timestamp,
  actor,
  tool_name
FROM trace
ORDER BY depth DESC, timestamp ASC;
```

**Purpose:** Full causal reconstruction. This is the most powerful
query in the schema — it walks backward from a final action (proof
submission) through every prior action that contributed to it. The
result is a complete decision tree showing how the agent arrived at
its output.

---

## Integrity Rules

**Rule 1 — Immutability**
No row is ever updated or deleted after creation. The only write
operation is `INSERT`. Any code path that attempts `UPDATE` or `DELETE`
on `audit_log` is a defect.

**Rule 2 — Server-Side Timestamps**
The `timestamp` field is written by the Nexus server, never supplied by
the caller. This prevents timestamp manipulation and ensures consistent
clock source.

**Rule 3 — Mandatory Reason**
For `write_` and `submit_` tools, the `reason` field must be non-null
and non-empty. The Zod schema must enforce this before the row is
written. A write action with no reason is untraceable and violates P5.

**Rule 4 — Source Audit ID Validity**
If `source_audit_id` is non-null, it must reference an existing
`audit_log.id`. The foreign key constraint enforces this. A dangling
source reference breaks chain of custody.

**Rule 5 — State Transition Completeness**
If `new_state` is non-null, `prior_state` must also be non-null. A
transition with no prior state is incomplete and makes Q4 queries
ambiguous.

**Rule 6 — Tool Name Conformance**
Every `tool_name` must conform to the tool grammar. A malformed tool
name makes the audit log unparseable. This is enforced at tool
registration time, not at audit write time — a malformed tool cannot
be registered in the first place.

---

## Performance Considerations

**Write performance is not a concern.** The audit log is write-once,
append-only, with no updates or deletes. SQLite handles this pattern
efficiently even at high volume.

**Read performance matters.** The audit log is queried frequently during
task diagnosis and retros. The four indexes defined in the schema cover
the common query patterns (Q1–Q8).

**Index coverage:**
- `idx_audit_task` covers Q1, Q4
- `idx_audit_actor` covers Q5, Q7
- `idx_audit_tool` covers Q3, Q6
- `idx_audit_timestamp` covers time-range queries in Q3, Q5, Q6, Q7

The recursive CTE in Q8 (chain of custody) requires no additional index
— it uses the primary key (`id`) and the foreign key (`source_audit_id`),
both of which are indexed by default.

**Growth rate estimate:**
Assuming 50 tool calls per task and 100 tasks per month:
- 5,000 rows/month
- 60,000 rows/year
- 300,000 rows over 5 years

SQLite handles this scale trivially. No partitioning or archival strategy
is needed at this volume.

---

## Relationship to Stream Events

The audit log and the stream events table serve different purposes:

| | `audit_log` | `stream_events` |
|---|---|---|
| **Audience** | Diagnostic (HA, FrameworkOwner) | Real-time monitoring (HA) |
| **Granularity** | Every tool call | State transitions only |
| **Format** | Structured, queryable | Plain English |
| **Retention** | Permanent | Windowed (30 days typical) |
| **Completeness** | Every action recorded | Summary only |

Stream events are derived from the audit log. When a tool causes a
state transition, it writes both:
1. An `audit_log` row (structured, permanent)
2. A `stream_events` row (plain English, windowed)

The stream event is a human-readable summary of the audit entry, not a
replacement. The audit log is the source of truth.

---

## Version History

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-03-04 | Initial schema. Grammar v0.3 applied. All eight canonical queries validated. H-SKILLS-01 confirmed no skill read audit entries needed. |

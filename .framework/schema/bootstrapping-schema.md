# Bootstrapping schema

- Enforces the principles (OCAP, audit, lifecycle, uncertainty, patterns).
- Supports the MCP tools you actually need in Zone 0 and for the first “build-the-framework” project.

Below is a concrete, implementable schema outline you can start from.

***

## 1. Core Tables Overview

At minimum, you need:

- `tasks` – work units + state machine.
- `features` – for grouping tasks (even if you only have “Build Nexus” at first).
- `audit_log` – all tool calls, immutable.
- `stream_events` – human-readable event stream.
- `documents` – typed artefacts (specs, proofs, AC, etc.).
- `agents` / `agent_instances` – templates and per-task instances.
- `patterns` / `pattern_evidence` – pattern library.
- `uncertainties` – uncertainty register.
- `context_packages` – curated context metadata.
- `tool_executions` (optional at first) – efficiency metrics if you want them separate from `audit_log`.

You can implement this in SQLite first; migrate to Postgres later without changing the logical model.

***

## 2. Tasks and Features

These anchor everything.

```sql
CREATE TABLE features (
  id               TEXT PRIMARY KEY,      -- e.g. 'feat-001'
  name             TEXT NOT NULL,
  description      TEXT NOT NULL,
  status           TEXT NOT NULL,         -- e.g. DRAFT, APPROVED, IN_PROGRESS, DONE
  created_at       DATETIME NOT NULL,
  updated_at       DATETIME NOT NULL
);

CREATE TABLE tasks (
  id               TEXT PRIMARY KEY,      -- e.g. 'task-001'
  feature_id       TEXT NOT NULL REFERENCES features(id),
  name             TEXT NOT NULL,
  description      TEXT NOT NULL,
  zone             INTEGER NOT NULL,      -- 1..5
  state            TEXT NOT NULL,         -- DEFINED, CONTEXT_READY, IN_PROGRESS, SUBMITTED, QA_PASSED, AWAITING_APPROVAL, APPROVED, DONE, BLOCKED, AWAITING_HUMAN, QA_FAILED
  created_at       DATETIME NOT NULL,
  updated_at       DATETIME NOT NULL,
  created_by       TEXT NOT NULL,         -- human or agent id
  current_assignee TEXT,                  -- optional: who’s currently “holding” it
  -- optional lightweight denorm:
  has_uncertainty  INTEGER NOT NULL DEFAULT 0
);
```

You can add a simple `task_state_transitions` table later if you want separate state history from `audit_log`, but the audit events will already contain it.

***

## 3. Documents (Specs, Proofs, AC, Context, etc.)

A generic document store works well with your tool grammar (subjects in `NexusToolGrammar.md`).

```sql
CREATE TABLE documents (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id          TEXT REFERENCES tasks(id),
  feature_id       TEXT REFERENCES features(id),
  subject          TEXT NOT NULL,          -- 'taskspec', 'prooftemplate', 'proof', 'worklog', 'featurespec', 'ac', 'qareview', 'contextcard', 'environmentcontract', 'uncertainty', 'decomposition', 'uibrief'
  version          INTEGER NOT NULL,
  path             TEXT NOT NULL,          -- filesystem path if you want it, or logical name
  content_hash     TEXT NOT NULL,
  created_at       DATETIME NOT NULL,
  created_by       TEXT NOT NULL,          -- agent or human
  UNIQUE (task_id, subject, version)
);
```

For append-only docs like `worklog` and `uncertainty`, you can either:

- Store each entry as a separate row in `documents` with incrementing `version`, or
- Add child tables `worklog_entries`, `uncertainty_entries`.

For bootstrapping, the single `documents` table is enough; you can add specialised tables later if needed.

***

## 4. Audit Log (All Actions Witnessed)

Keep it simple and append-only. This is the backbone.

```sql
CREATE TABLE audit_log (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp        DATETIME NOT NULL,
  actor_type       TEXT NOT NULL,         -- 'agent', 'human', 'webhook-github', 'system'
  actor_id         TEXT NOT NULL,         -- e.g. 'TaskPerformer_task-001', 'FrameworkOwner'
  tool_name        TEXT NOT NULL,         -- e.g. 'readtaskspec', 'submitproof_task001'
  task_id          TEXT,                  -- nullable for global tools
  feature_id       TEXT,
  input_summary    TEXT,                  -- optional JSON-ish payload or short summary
  output_summary   TEXT,                  -- optional
  content_hash     TEXT,                  -- relevant document or result hash
  status           TEXT NOT NULL,         -- 'OK', 'ERROR'
  error_message    TEXT,                  -- if status = ERROR
  token_in         INTEGER,               -- efficiency metrics
  token_out        INTEGER,
  latency_ms       INTEGER
);
```

You can enforce immutability at the application layer (never issue UPDATE/DELETE), or later via DB constraints.

***

## 5. Stream Events (Human-Facing)

This feeds your “Pete stream” / FO events.

```sql
CREATE TABLE stream_events (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp        DATETIME NOT NULL,
  type             TEXT NOT NULL,         -- e.g. 'TaskCreated', 'TaskStateChanged', 'UncertaintyRaised', 'AgentClassCreated'
  task_id          TEXT,
  feature_id       TEXT,
  actor_id         TEXT,
  message          TEXT NOT NULL          -- human-readable
);
```

Many `stream_events` rows will be produced inside compound tools like `submitprooftaskNN`.

***

## 6. Agents and Instances (Zone 0, Bootstrapping)

Separate templates (classes) from per-task instances.

```sql
CREATE TABLE agents (
  id               TEXT PRIMARY KEY,      -- e.g. 'TaskPerformer', 'QAExecutor'
  zone             INTEGER NOT NULL,      -- primary zone of operation
  type             TEXT NOT NULL,         -- 'ORCHESTRATOR','EXECUTOR','REVIEWER','ADVISOR'
  description      TEXT NOT NULL,
  template_path    TEXT NOT NULL,         -- .github/agents/...agent.md
  nv_score         INTEGER NOT NULL,      -- 0..3, from Agent Creation Policy [file:1]
  blast_radius     INTEGER NOT NULL,      -- 0..4, from Agent Creation Policy [file:1]
  qa_tier          INTEGER NOT NULL,      -- 1..4
  created_at       DATETIME NOT NULL,
  created_by       TEXT NOT NULL
);

CREATE TABLE agent_instances (
  id               TEXT PRIMARY KEY,      -- e.g. 'TaskPerformer_task-001'
  agent_id         TEXT NOT NULL REFERENCES agents(id),
  task_id          TEXT REFERENCES tasks(id),
  spec_path        TEXT NOT NULL,         -- path to instance .agent.md
  created_at       DATETIME NOT NULL,
  destroyed_at     DATETIME
);
```

This matches the per-task instance decision in `NexusModelOverview.md` and `NexusDecisionsRationale.md`. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/a140e0d6-1785-463e-84eb-e9fa838f81b3/NexusModelOverview.md)

***

## 7. Patterns and Evidence (Pattern Library)

This can start minimal; you don’t need full sophistication for bootstrapping.

```sql
CREATE TABLE patterns (
  id               TEXT PRIMARY KEY,      -- 'pat-001'
  name             TEXT NOT NULL,
  description      TEXT NOT NULL,
  tags             TEXT,                  -- comma-separated for now
  status           TEXT NOT NULL,         -- 'candidate','active','retired'
  nv_score         INTEGER NOT NULL DEFAULT 0,
  created_at       DATETIME NOT NULL,
  created_by       TEXT NOT NULL
);

CREATE TABLE pattern_evidence (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  pattern_id       TEXT NOT NULL REFERENCES patterns(id),
  task_id          TEXT,
  agent_id         TEXT,
  timestamp        DATETIME NOT NULL,
  outcome          TEXT NOT NULL,         -- 'positive','negative'
  notes            TEXT
);
```

`searchKnowledgeBase` can query this pair for now (plus any later tables you add).

***

## 8. Uncertainties

Your uncertainty protocol is already defined in `preflight-check-protocol.md` and `zone-uncertainty-analysis.md`. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/85229eca-47a0-4539-831e-7d6f37d94b1c/preflight-check-protocol.md)

```sql
CREATE TABLE uncertainties (
  id               TEXT PRIMARY KEY,      -- 'unc-001'
  task_id          TEXT REFERENCES tasks(id),
  feature_id       TEXT REFERENCES features(id),
  zone             INTEGER NOT NULL,      -- 0..5
  raised_by        TEXT NOT NULL,         -- agent or human id
  raised_at        DATETIME NOT NULL,
  status           TEXT NOT NULL,         -- 'OPEN','IN_RESEARCH','MITIGATION_PROPOSED','RESOLVED','CLOSED'
  description      TEXT NOT NULL,         -- free text 'what / why'
  needed           TEXT,                  -- 'what information is needed'
  context_paths    TEXT                   -- serialized list of file paths
);

CREATE TABLE uncertainty_actions (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  uncertainty_id   TEXT NOT NULL REFERENCES uncertainties(id),
  timestamp        DATETIME NOT NULL,
  actor_id         TEXT NOT NULL,
  action_type      TEXT NOT NULL,         -- 'RESEARCHED','MITIGATION_DEFINED','MITIGATION_ACCEPTED','MITIGATION_REJECTED','ESCALATED_TO_FO','CLOSED'
  details          TEXT
);
```

This supports the cross-zone P.U policies you already defined. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/2844a831-359e-4c78-8899-f2166d0b2fcf/zone-uncertainty-analysis.md)

***

## 9. Context Packages

The context curation pattern is formalised in its own doc. You can store only metadata here; the actual context package remains in the repo. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/627df371-76c7-43de-bc39-f7e6206d3347/context-curation-pattern.md)

```sql
CREATE TABLE context_packages (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id          TEXT NOT NULL REFERENCES tasks(id),
  zone             INTEGER NOT NULL,      -- usually 3 or 5
  status           TEXT NOT NULL,         -- 'CURATED','REVIEWED','APPROVED','INVALIDATED'
  curator_id       TEXT NOT NULL,         -- ContextAgent instance
  reviewer_id      TEXT,                  -- QA Definition
  approver_id      TEXT,                  -- FO for invariant gates
  curated_at       DATETIME NOT NULL,
  reviewed_at      DATETIME,
  approved_at      DATETIME,
  invalidated_at   DATETIME,
  package_path     TEXT NOT NULL          -- e.g. '.../task/context-package.md'
);
```

If a source artefact changes, you set `status='INVALIDATED'` and `invalidated_at` and force re-curation.

***

## 10. Tool Executions (Optional but Nice For Efficiency)

You can keep this separate from `audit_log` if you want higher-resolution efficiency metrics.

```sql
CREATE TABLE tool_executions (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  audit_id         INTEGER NOT NULL REFERENCES audit_log(id),
  model_name       TEXT,                  -- 'gpt-5.1', etc.
  token_in         INTEGER,
  token_out        INTEGER,
  latency_ms       INTEGER,
  cost_estimate    REAL                   -- if you want to compute $
);
```

This is not essential for bootstrapping, but if you want to observe efficiency from day one, it’s worth adding.

***

## How This Supports Zone 0 MCP Tools

With this schema, the first Zone 0 / MCP tools you design can:

- `readTaskSpec` / `writeTaskSpec`:
  - Hit `documents` with `subject='taskspec'`, plus `tasks` for metadata.
- `submitProof`:
  - Write to `documents` with `subject='proof'`.
  - Update `tasks.state`.
  - Insert into `audit_log`.
  - Insert into `stream_events`.
- `raiseUncertainty`:
  - Insert into `uncertainties` + `uncertainty_actions`.
  - Set `tasks.state='BLOCKED'`.
  - Insert stream event.
- `getContextCard`:
  - Read `context_packages` metadata + relevant `documents`.
- `searchKnowledgeBase`:
  - Query `patterns` + `pattern_evidence`.
- `Agent Creation` tools:
  - `AgentClassCreated` is recorded in `agents`, `audit_log`, `stream_events`.
  - Agent template path stored in `agents.template_path`.

You can implement these tools against SQLite quickly and iterate.

If you’d like next, we can:

- Turn this into a concrete `schema.sql` you can drop into the repo, or
- Start from a minimal subset (e.g. only `features`, `tasks`, `documents`, `audit_log`, `stream_events`, `agents`, `agent_instances`) for the very first dogfood cycle and add `uncertainties`, `patterns`, etc., as you wire those flows.
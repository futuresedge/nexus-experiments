# Nexus Tool Grammar — Reference Specification

**Version:** 0.3
**Status:** Active
**Principles implemented:** P3, P4, P5, P12, P16
**Platform constraint reference:** .framework/policies/platform-constraints.md
**Naming conventions reference:** .framework/policies/naming-conventions.md
**Last Updated:** 2026-03-04

---

## Version History

| Version | Date | Change | Principle |
|---|---|---|---|
| 0.1 | 2026-03-01 | Initial grammar. All verbs defined. Tool Matrix established. | P3, P4, P12 |
| 0.2 | 2026-03-02 | `get_` promoted to audit-writing verb. Rationale: system state reads must be traceable. Discovered via H5 chain-of-custody test. | P5 partial |
| 0.3 | 2026-03-03 | `read_` and `search_` promoted to audit-writing verbs. Rationale: P5 requires every action by every agent to be recorded — including reads. The v0.2 distinction between "mutable system state" (audited) and "versioned documents" (not audited) is insufficient. A document version number records what the document contained; it does not record who read it, when, or what they did with it. Rule 5 updated accordingly. Named Decision D-009. | P5 |

---

## Purpose

This grammar defines the naming, structure, and behavioural contract for
every tool in the Nexus MCP server. It exists to prevent the tool catalogue
from becoming an unmaintainable list of ad hoc names as the framework grows.
Any developer or agent adding a new tool must derive it from this grammar —
not invent independently.

The grammar enforces one principle above all others: **tool possession is
capability** (P3). The name of a tool must be sufficient to determine what
it does, who should have it, and what scope it acts on — without consulting
any other document.

### Why This Grammar Is Load-Bearing, Not Stylistic (P12)

Naming conventions in this framework are structural elements. The
`{verb}_{subject}_{task_slug}` format is not cosmetic:

- It makes every audit log row self-describing without a schema join
- It makes the chain of custody reconstructable by a human with no
  prior knowledge of the database schema
- It makes tool capability derivable by inspection — no tool registry
  documentation needed
- It makes violations of the grammar visible immediately — a malformed
  name signals a design problem, not a naming preference

A single deviation from this grammar creates a gap in traceability that
may only surface during a failure diagnosis. Treat deviations as defects.

### Relationship to the Platform (P3, P16)

These tools exist in the Nexus MCP layer — the access-controlled layer of
the framework. They are the mechanism by which write authority is enforced
between agent classes, because the VS Code platform provides no other way
to scope filesystem write access.

See `.framework/policies/platform-constraints.md` for the full explanation
of why MCP tools are the access control boundary, and which agents hold the
VS Code edit tool instead.

---

## The Grammar

Every tool name is formed from two or three components:

```
{verb}_{subject}

or, for task-scoped tools:

{verb}_{subject}_{task_slug}
```

Where:
- `{verb}` is drawn from the closed Verb Vocabulary (8 entries, never
  extended without a framework-level decision)
- `{subject}` is drawn from the open Subject Vocabulary (document type
  taxonomy, extends as the framework grows)
- `{task_slug}` is the task identifier with hyphens replaced by
  underscores (`task-07` → `task_07`)

**No other components are permitted.** A tool name with an adjective, a
preposition, a conjunction, or any component not in these vocabularies is
malformed and must be redesigned.

---

## Verb Vocabulary

The verbs are a **closed set**. New verbs are never added without a
framework-level decision and update to this document. If a proposed tool
doesn't fit an existing verb, the answer is almost always that the tool is
crossing a concern boundary and should be split.

### Audit Obligation Summary

Every verb in the grammar produces an audit entry. This is a P5 invariant
— it is not optional and cannot be relaxed for individual tools.

| Verb | Audit entry? | State transition? | Stream event? |
|---|---|---|---|
| `read_` | ✅ | ❌ | ❌ |
| `write_` | ✅ | ❌ | ❌ |
| `append_` | ✅ | ❌ | ❌ |
| `submit_` | ✅ | ✅ | ✅ |
| `request_` | ✅ | ✅ (→ AWAITING only) | ✅ |
| `search_` | ✅ | ❌ | ❌ |
| `get_` | ✅ | ❌ | ❌ |
| `raise_` | ✅ | ✅ (→ BLOCKED) | ✅ (priority) |

---

### `read_`

**Semantics:** Fetch the current content of a document. Returns document
content only.

**Principles:** P5 (every action recorded), P3 (tool possession defines
access)

**Side effects:**
Writes one `audit_log` entry:
```json
{
  "tool_name": "read_task_spec_task_07",
  "actor": "task-performer:task-07",
  "task_id": "task-07",
  "doc_version_hash": "sha256:abc123..."
}
```
No state change. No stream event.

**Why `doc_version_hash` is required:**
The version number records what the document contained. The audit entry
records who read it and when. These answer different questions. "The agent
read task_spec v3" tells you what information was available. "The agent
read task_spec v3 at 14:22 before submitting proof at 14:45" tells you what
information the agent was working from when it made a decision. Both are
necessary for a complete causal chain.

**Rules:**
- Must be idempotent — calling it twice returns identical content and
  produces two identical audit entries (the second is not an error)
- Must never mutate any database row other than `audit_log`
- Any agent may receive a `read_` tool for any document type relevant
  to its role — access is controlled by tool possession, not by a
  runtime permission check
- If a document does not exist, return a typed empty response — never
  an error that leaks schema details

**How `read_` differs from `get_`:**
Both now produce audit entries. The distinction is what they operate on:
- `read_` operates on task documents — typed, versioned content artefacts
  with a defined lifecycle. Returns document content.
- `get_` operates on system state resources — context cards, capability
  registries, lifecycle state. Returns structured metadata, not document
  content. See `get_` definition below.

**Examples:** `read_task_spec_task_07`, `read_proof_template_task_07`,
`read_qa_review_task_07`

**Counter-example:** `read_context_card` called by an agent loading its own
context ❌ — an agent loading its own context card calls `get_context_card`,
not `read_context_card`. `read_context_card` is reserved for roles that
inspect another agent's card as a governed document (e.g. the FrameworkOwner
auditing what card a given agent class was issued). These are different
operations with different semantics.

---

### `write_`

**Semantics:** Create or fully replace a document. The previous version is
preserved in document history; the current pointer updates.

**Principles:** P4 (mandatory side effects inside tools), P5 (every action
recorded)

**Side effects:**
Writes one `audit_log` entry:
```json
{
  "tool_name": "write_task_spec_task_07",
  "actor": "task-owner:task-07",
  "task_id": "task-07",
  "doc_version_hash": "sha256:def456...",
  "reason": "Updated to include Redis dependency"
}
```
No state transition. No stream event.

**Rules:**
- Requires a mandatory `reason` parameter — the Zod schema must enforce
  this; it cannot be optional or empty string
- If the document already exists, creates a new version (never destructive
  — the previous version remains in history)
- Must validate that the task is in a state that permits writes for this
  document type — reject with a typed error if not
- Never used for append-only documents (use `append_` instead)
- Never used when a state transition must follow (use `submit_` instead)

**Examples:** `write_task_spec_task_07`, `write_feature_spec`,
`write_proof_template_task_07`

**Counter-example:** `write_proof_task_07` ❌ — proof submission requires a
state transition; this must be `submit_proof_task_07`.

---

### `append_`

**Semantics:** Add an entry to an append-only document. The document is an
ordered log; prior entries are never modified.

**Principles:** P4, P5

**Side effects:**
Writes one `audit_log` entry:
```json
{
  "tool_name": "append_work_log_task_07",
  "actor": "task-performer:task-07",
  "task_id": "task-07",
  "entry_hash": "sha256:ghi789...",
  "entry_preview": "First 80 chars of appended entry for log readability"
}
```
No state transition. No stream event.

**Rules:**
- Only applicable to subjects explicitly designated as Append-only in the
  Subject Vocabulary — applying `append_` to a Replace-mode subject is a
  grammar violation
- Must never accept a `replace` or `overwrite` parameter
- Timestamps are written by the server, not the caller — the caller cannot
  specify or override a timestamp
- The `entry_hash` in `audit_log` covers the appended entry only, so
  individual entries are independently traceable

**Applicable subjects:** `work_log`, `uncertainty` (log entries),
`decomposition` (task additions only)

**Examples:** `append_work_log_task_07`, `append_uncertainty_task_07`

**Counter-example:** `append_task_spec_task_07` ❌ — `task_spec` is a
Replace-mode document. This is a grammar violation.

---

### `submit_`

**Semantics:** Write a document AND trigger a state transition AND emit a
stream event. All three operations are atomic — all succeed or none do.

**Principles:** P4 (mandatory side effects inside tools), P5, P6 (evidence
not assertion — the submitted document is the literal evidence)

**Side effects (all atomic):**
1. Writes the document with version history
2. Writes one `audit_log` entry
3. Transitions the entity state (specific transition hardcoded per tool)
4. Emits a `stream_events` entry in plain English
5. Triggers the Policy Engine to evaluate downstream policies

**Rules:**
- Exactly one state transition per `submit_` call — if two transitions
  are needed, it is two tools
- The stream event text is hardcoded in the tool implementation — the
  caller cannot supply or modify the stream message
- Must validate that the current state is the exact expected
  pre-transition state; reject with a typed error if not
- The `reason` parameter is mandatory, as per `write_`
- No `submit_` tool is given to an agent that is not the designated
  actor for that transition (P8 — separation of execution and
  verification)

**Examples:** `submit_proof_task_07`, `submit_qa_review_task_07`,
`submit_ac`

**Counter-example:** `submit_context_card` ❌ — context cards are generated
by the system, not submitted by agents.

---

### `request_`

**Semantics:** Signal intent or request action from another actor. Writes
no documents. Does not advance state to an active working state
unilaterally.

**Principles:** P4, P5, P9 (fail loudly — `request_` is how an agent
signals it needs something before it can proceed, without guessing)

**Side effects:**
Writes one `audit_log` entry. Emits a `stream_events` entry identifying
the target actor. May transition state to an `AWAITING_*` state — but
never to an active working state.

**Rules:**
- Never writes a document
- The requested action must be taken by a different actor — `request_`
  is never self-fulfilling
- The stream event must identify who the request is directed at
  (HumanApprover, QAExecutor, FeatureOwner)
- Used when an agent needs a cross-role action before it can continue

**Examples:** `request_review`, `request_clarification`,
`request_ac_approval`

**Counter-example:** `request_write_task_spec` ❌ — verbs do not nest.

---

### `search_`

**Semantics:** Query the Pattern Library or knowledge base. Returns
matching entries ranked by relevance.

**Principles:** P5 (every action recorded — what an agent searched for
and what it found is causally significant), P7 (minimum sufficient context
— agents search for relevant patterns rather than receiving all patterns)

**Side effects:**
Writes one `audit_log` entry:
```json
{
  "tool_name": "search_knowledge_base",
  "actor": "task-performer:task-07",
  "query": "login form validation patterns",
  "tags": ["zone-4", "validation"],
  "result_count": 3,
  "top_entry_ids": ["pat-001", "pat-002", "pat-003"]
}
```
No state change. No stream event.

**Why query and results are recorded:**
An audit entry with only a timestamp answers "did the agent search?"
Recording the query and top results answers "what did the agent look for,
and what did it find?" The second question is the one that matters for
diagnosing whether an agent had access to relevant patterns before making
a decision. If an agent produced a poor output on a task type that has a
known Pattern Library entry, the audit log will show whether it searched
for that pattern or not.

**Rules:**
- Must accept a `query` parameter (free text)
- Must accept an optional `tags` parameter for category filtering
- Must never return content from the primary document store — only
  Pattern Library and knowledge base entries
- Results must include `source_session` so the caller knows when the
  pattern was recorded
- Returns summaries, not full content — an agent needing full content
  must have a `read_` tool for that pattern document

**Examples:** `search_knowledge_base`, `search_patterns`

**Counter-example:** `search_task_specs` ❌ — primary document search is
`read_` with a filter parameter, not `search_`. The `search_` verb is
reserved for the knowledge base only.

---

### `get_`

**Semantics:** Fetch system-level metadata, configuration, or pre-generated
artefacts. Distinct from `read_` in that it operates on system resources,
not task documents.

**Principles:** P5, P7 (context cards provide minimum sufficient context
to agents at instantiation)

**Side effects:**
Writes one `audit_log` entry:
```json
{
  "tool_name": "get_context_card",
  "actor": "task-performer:task-07",
  "resource_version": "v3",
  "resource_hash": "sha256:mno345..."
}
```
No state change. No stream event.

**How `get_` differs from `read_` (v0.3 distinction):**

Both verbs now produce audit entries. The distinction is the nature of
what they access, not their audit behaviour:

| Dimension | `read_` | `get_` |
|---|---|---|
| Operates on | Task documents | System state resources |
| Returns | Document content | Structured metadata |
| Subject vocabulary | Document types (task_spec, proof, etc.) | System resources (context_card, capabilities, current_state) |
| Version model | Document version history | Resource regenerated externally (e.g. context cards regenerated by ContextCurator) |
| Audit records | `doc_version_hash` — which doc version | `resource_version` — which system state snapshot |

**Rules:**
- Never operates on a task document — that is `read_`
- Returns structured data, not raw document content
- The audit entry must capture the version or value of the resource
  returned — not just that it was fetched

**Examples:** `get_context_card`, `get_my_capabilities`,
`get_current_state`

**Counter-example:** `get_task_spec_task_07` ❌ — task specs are documents,
not system metadata. This must be `read_task_spec_task_07`.

---

### `raise_`

**Semantics:** Surface an exceptional condition immediately to human
attention. Bypasses normal workflow.

**Principles:** P9 (fail loudly, never silently), P10 (irreversible
states require human authority — BLOCKED state is entered here)

**Side effects:**
Writes one priority `audit_log` entry. Emits a priority `stream_events`
entry (visually distinct from standard events — HumanApprover sees this
immediately). If `severity == BLOCKED`: transitions entity state to
`BLOCKED` or `AWAITING_HUMAN`.

**Rules:**
- Reserved exclusively for the `uncertainty` subject — `raise_uncertainty`
  is the only valid `raise_` tool in the grammar
- Must never be used for normal workflow signalling — use `request_` for
  cross-agent coordination
- The description fields (`what`, `why`, `needed`) are free text — this
  is intentional; uncertainties are by definition unstructured
- Any agent may hold this tool — it is a safety valve, not a privilege
  (P9 applies in every zone, at every role level)
- A `raise_uncertainty` call with no `context_paths` is invalid — an
  uncertainty with no traceable context cannot be resolved

**Example:** `raise_uncertainty`

**Counter-example:** `raise_error` ❌ — tool errors are handled by the
tool's typed return value. `raise_` is exclusively for conditions requiring
human attention that cannot be resolved within the normal flow.

---

## Subject Vocabulary

Subjects are an **open set** — new document types are added as the
framework encounters them. Each entry defines the write mode, valid verbs,
and owning role.

| Subject | Write mode | Valid verbs | Owner role | |
|---|---|---|---|--|
| `task_spec` | Replace | `read`, `write` | TaskOwner | |
| `proof_template` | Replace | `read`, `write` | ProofDesigner | |
| `proof` | Create-once | `read`, `submit` | TaskPerformer | |
| `work_log` | Append-only | `read`, `append` | TaskPerformer | |
| `feature_spec` | Replace | `read`, `write` | FeatureOwner | |
| `ac` | Replace | `read`, `write`, `request` | FeatureOwner | |
| `qa_review` | Create-once | `read`, `submit` | QAExecutor | |
| `context_card` | Replace | `read`, `write`, `get` | ContextCurator (`write`); any agent (`get`) | |
| `environment_contract` | Replace | `read`, `write` | TaskOwner | |
| `uncertainty` | Append-only | `read`, `append`, `raise` | Any (cross-cutting) | |
| `decomposition` | Append + Replace | `read`, `write`, `append` | FeatureOwner | |
| `ui_brief` | Replace | `read`, `write` | UIDesigner | |
| `knowledge_base` | Append-only | `search`, `append` | ContextCurator (`append`); any agent (`search`) | |
| `pattern` | Listed as `write_pattern` and `search_patterns` in agent sketches, but no formal Subject Vocabulary entry exists | Add row: Replace mode for individual pattern entries; `search_patterns` is the query interface; `submit_pattern` promotes a CANDIDATE to PROVISIONAL (FrameworkOwner only) |
| `agent_template` | `write_agent_template` mentioned in TemplateAuthor sketch but not in Subject Vocabulary | Add row: Replace mode; owned by `TemplateAuthor`; `submit_agent_template` triggers `AgentSpecReviewer` activation |
| `capabilities` | System | `get` | Nexus server (read-only) | |
| `current_state` | System | `get` | Nexus server (read-only) | |
| `project_manifest` | Replace | read, write, submit | `ProjectRegistrar` | One per project. `submit_project_manifest` transitions to `MANIFEST_APPROVED` and emits priority stream event to `human:director` |
| `bootstrap_report` | Create-once | read, write, submit | `BootstrapValidator` | `submit_bootstrap_report` transitions Bootstrap cycle to `AWAITING_HUMAN` and emits priority stream event to `human:director` |
| `spec_tests` | Replace | read, write, submit | `AgentSpecReviewer` | Spec tests for a proposed agent template. `submit_spec_tests` signals FrameworkOwner to review before TemplateAuthor begins |

**Note on `context_card`:**
The `context_card` subject has both `read_` and `get_` tools. These are
not duplicates:
- `get_context_card` — universal tool, called by an agent loading its
  own context at instantiation. This is the agent-facing tool.
- `read_context_card` — role-scoped tool, called by the FrameworkOwner or
  ContextCurator to inspect what card a given agent class was issued. This
  treats the context card as a governed document to be reviewed, not loaded.

**Rules for adding a new subject:**
1. It must represent a distinct document type not covered by any existing
   subject
2. It must have a designated owner role with exclusive `write_` authority
3. Its write mode must be declared before any tool is built
4. Adding a subject does not create tools — only matrix cells that make
   domain sense become tools

---

## The Tool Matrix

✓ = tool exists or will exist. Blank = combination is not domain-valid.

| | `read_` | `write_` | `append_` | `submit_` | `request_` | `search_` | `get_` | `raise_` |
|---|---|---|---|---|---|---|---|---|
| `task_spec` | ✓ | ✓ | | | | | | |
| `proof_template` | ✓ | ✓ | | | | | | |
| `proof` | ✓ | | | ✓ | | | | |
| `work_log` | ✓ | | ✓ | | | | | |
| `feature_spec` | ✓ | ✓ | | | | | | |
| `ac` | ✓ | ✓ | | | ✓ | | | |
| `qa_review` | ✓ | | | ✓ | | | | |
| `context_card` | ✓ | ✓ | | | | | ✓ | |
| `environment_contract` | ✓ | ✓ | | | | | | |
| `uncertainty` | ✓ | | ✓ | | | | | ✓ |
| `decomposition` | ✓ | ✓ | ✓ | | | | | |
| `ui_brief` | ✓ | ✓ | | | | | | |
| `knowledge_base` | | | ✓ | | | ✓ | | |
| `patterns` | ✓ | ✓ | | | | ✓ | | |
| `capabilities` | | | | | | | ✓ | |
| `current_state` | | | | | | | ✓ | |
| `project_manifest` | ✓ | ✓ | | ✓ | | | | |
| `bootstrap_report`  | ✓ | ✓ | | ✓ | | | | |
| `spec_tests` | ✓ | ✓ | | ✓ | | | | |
| `pattern` | ✓ | ✓ | | ✓ | | ✓ | | |
| `agent_template` | ✓ | ✓ | | ✓ | | | | |

---

## Scoping Rules

### Universal tools (no task suffix)
Available to every agent, always. No task suffix because they are not
scoped to any single task.

```
get_context_card          search_knowledge_base
get_my_capabilities       raise_uncertainty
get_current_state
```

### Role-scoped tools (no task suffix)
Available to an agent class across all tasks. The tool validates permitted
access against the calling agent's role from its context card.

```
read_feature_spec         write_feature_spec
read_ac                   write_ac
read_decomposition        write_decomposition
read_patterns             write_patterns
append_knowledge_base
```

### Task-scoped tools (with task suffix)
Dynamically generated per active task. The suffix is the task identifier
with hyphens replaced by underscores.

**Formation rule:**
```
task-07  →  _task_07    task-07a →  _task_07a
```

**Examples:**
```
read_task_spec_task_07
write_proof_template_task_07
append_work_log_task_07
submit_proof_task_07
read_environment_contract_task_07
```

**Why underscores:** Hyphens in tool names create parsing ambiguity when
extracting `task_id` by splitting on `_`. Underscores produce unambiguous
splits — the final segment after `_{subject}_` is always the task slug.

---

## Rules for Designing New Tools

Apply in order. Stop and redesign if any rule rejects.

**Rule 1 — One verb.**
Map the proposed operation to exactly one verb. If it maps to two verbs,
it is two tools. If it maps to zero verbs, escalate to a framework-level
decision — do not invent a verb unilaterally.

**Rule 2 — One subject.**
Each tool operates on exactly one subject. A tool that reads one document
type and writes another is two tools.

**Rule 3 — Matrix check.**
Verify the verb × subject cell is marked ✓ in the Tool Matrix. If it is
blank, the combination is not domain-valid. Do not fill blank cells to
satisfy edge cases without confirming at the domain model level.

**Rule 4 — Scope determination.**
Classify as universal, role-scoped, or task-scoped. Universal tools are
rare — only tools that genuinely serve every agent without any task
context. When in doubt, task-scope it.

**Rule 5 — Side effect audit.**
List every side effect. Then verify:

```
Side effects              → Correct verb
────────────────────────────────────────────────
Audit entry only          → read_, search_, or get_
Audit + doc write         → write_ or append_
Audit + doc + transition  → submit_
Audit + stream event only → request_ or raise_
```

If any side effect is absent from the implementation when the verb
requires it, this is a Rule 6 violation, not a Rule 5 violation.

**Rule 6 — Mandatory consequences inside the tool (P4).**
Every side effect listed for a verb must be implemented inside the tool,
not described to the agent as a follow-up instruction. If an agent spec
currently says "after calling X, also write to the audit log" — that is a
Rule 6 violation. The audit write belongs inside X.

This rule applies to audit entries specifically: as of v0.3, no tool in
the grammar has zero side effects. Any tool implementation that does not
write an audit entry is non-compliant regardless of verb.

---

## Well-Formed and Malformed Examples

```
✅  read_task_spec_task_07         verb=read,   subject=task_spec,      scope=task_07
✅  submit_proof_task_07           verb=submit, subject=proof,           scope=task_07
✅  append_work_log_task_07        verb=append, subject=work_log,        scope=task_07
✅  get_context_card               verb=get,    subject=context_card,    scope=universal
✅  raise_uncertainty              verb=raise,  subject=uncertainty,     scope=universal
✅  search_knowledge_base          verb=search, subject=knowledge_base,  scope=universal
✅  request_ac_approval            verb=request,subject=ac,              scope=role

❌  finalize_feature               'finalize' is not in the Verb Vocabulary
❌  write_and_submit_proof_task_07  two verbs — must be split
❌  get_task_spec_task_07          task_spec is a document, not metadata → read_
❌  submit_context_card            context cards are not submitted by agents
❌  append_task_spec_task_07       task_spec is Replace mode, not Append-only
❌  write_proof_task_07            proof is Create-once with state transition → submit_
❌  task_07_write_proof            wrong component order — verb must come first
```

---

## Versioning This Document

Changes to the grammar fall into three categories:

- **Adding a subject** (most common): add to Subject Vocabulary, add row
  to Tool Matrix, update affected agent spec templates. Bump patch version.
- **Adding a tool to an existing subject** (occasional): fill a blank
  matrix cell, implement the tool, confirm Rules 5 and 6. Bump patch
  version.
- **Adding a verb or changing verb semantics** (rare — framework-level
  decision required): update this document, the Tool Matrix, all agent
  spec templates, and all `tools/list` logic in the Nexus server. Bump
  minor version. Record as a Named Decision in the manifest.
# Step 6 Policy: Human Readiness Confirmation

**Version:** 0.1 — Draft
**Depends on:** Step 5 `bootstrap-report.md` with verdict `PASS` or `PASS_WITH_GAPS`
**Note on FAIL verdict:** A `FAIL` bootstrap report means Step 5 is not done. Step 6 cannot begin until Step 5 produces a `PASS` or `PASS_WITH_GAPS` verdict.
**Completes:** The bootstrapping phase. An `APPROVED` decision in this step is the irreversible boundary between bootstrapping and delivery.

***

## Overview

Step 6 answers one question: *Does the person accountable for this project confirm, with full awareness of what has been verified and what gaps remain, that the system is ready to begin delivery work?*

This step is structurally unlike Steps 1–5. The primary actor is `human:director`. The role of every automated or supporting process in this step is to ensure that human has everything they need to make a genuinely informed decision — not to make the decision easier or to guide them toward a particular outcome.

The decision itself is irreversible. Once `APPROVED`, bootstrapping is closed. The first delivery task can be created. That closure cannot be undone without restarting the bootstrapping phase in full. Per **L2**, this kind of one-way decision requires a present, clearly responsible human making a conscious call — not a passive sign-off, not a default, not a timeout.

There are two things this step must guarantee:

**Informed.** The human reviewed the bootstrap report, not a summary of it. They reviewed the gap list, if one exists, and explicitly acknowledged each non-blocking gap they are choosing to accept. They had access to the underlying evidence for any check they wanted to examine. Their decision is based on actual knowledge, not assumption about what the report says.

**On record.** The decision, its timestamp, the identity of the decision-maker, the report version it was based on, and any gap acknowledgements are recorded in a decision record that cannot be modified after creation. The record is the proof that the decision was made consciously — not the `APPROVED` field in a document, which is only a state.

A `RETURNED_WITH_ITEMS` decision is not a failure state — it is a legitimate outcome. It means `human:director` reviewed the report and determined that specific items, blocking or non-blocking, must be addressed before they are willing to proceed. The returned items are specific, not general. They go back to the relevant steps with clear remediation targets.

***

## Inputs

### Summary

| Input | Source | Requirement | If Absent |
|---|---|---|---|
| `bootstrap-report.md` with verdict `PASS` or `PASS_WITH_GAPS` | Step 5 | **REQUIRED** | Hard blocker — Step 6 cannot begin |
| Gap list within the report | Step 5 | Conditional | Required if verdict is `PASS_WITH_GAPS`; absent for `PASS` |
| Access to underlying evidence for all prior steps | Steps 1–5 | **REQUIRED** | Human cannot make an informed decision without ability to examine evidence |
| Readiness package | Task 6.1 | **REQUIRED** | Structured presentation of the report and navigation to evidence |
| Decision record template | Toolkit | **REQUIRED** | No schema for recording the decision |

### Detailed Input Specifications

#### `bootstrap-report.md`

| Criterion | Requirement |
|---|---|
| **Verdict** | Must be `PASS` or `PASS_WITH_GAPS` — `FAIL` is not a valid input to Step 6 |
| **Completeness** | All four check sections must be present: document checks (8 items), infrastructure checks (6 components), smoke test results (8 steps), audit log completeness record |
| **Gap list** | If `PASS_WITH_GAPS`: gap list must be present with all non-blocking gaps classified and described. `human:director` must be able to read the gap list and understand each gap without needing to read the full report to understand the context |
| **Version** | The report reviewed must be the report produced at the end of Step 5 — not a prior draft, not a summary produced for convenience |

#### Access to underlying evidence

`human:director` must be able to navigate from any check item in the bootstrap report to the underlying evidence for that item. This does not mean they must review all of it — it means the access must exist so their decision to rely on the report's summary is an informed choice, not a forced one.

| Evidence accessible | Location |
|---|---|
| `project-manifest.md` | `[project-root]/.framework/project-manifest.md` |
| `environment-contract.md` | `[project-root]/.framework/environment-contract.md` |
| All role definitions | `[project-root]/.github/agents/` |
| Role verification records | `[project-root]/.framework/verification/` |
| Pattern library entries | `[project-root]/.framework/pattern-library/` |
| Smoke test audit log entries | Nexus audit log, queryable by `smoke-01` task identifier |

#### Readiness package

The readiness package is not a new document — it is a structured navigation aid that ensures `human:director` can move efficiently from high-level verdict to specific evidence. Its purpose is to reduce the effort of being informed, not to replace the underlying evidence.

| Component | Requirement |
|---|---|
| Bootstrap report (full) | Linked or embedded — not paraphrased or summarised |
| Gap list (if present) | Presented prominently — not buried in the report body |
| Navigation index | Direct links to each prior step output and its verification record |
| Decision prompt | An explicit statement of what `human:director` is being asked to decide, what `APPROVED` means, and that the decision is irreversible |
| Gap acknowledgement prompts | One prompt per non-blocking gap — each prompt states the gap and asks for explicit acknowledgement before the `APPROVED` decision is available |

***

## Outputs

### Summary

| Output | Requirement | If Absent |
|---|---|---|
| Decision record with `APPROVED` or `RETURNED_WITH_ITEMS` | **REQUIRED** | BLOCKER — bootstrapping is neither complete nor returned for remediation |
| Explicit acknowledgement for each non-blocking gap (if PASS_WITH_GAPS) | **REQUIRED** | BLOCKER — APPROVED decision without gap acknowledgement is not an informed decision |
| Bootstrap lifecycle state transition to `CLOSED` (if APPROVED) | **REQUIRED** | BLOCKER — system does not know bootstrapping is complete |
| Remediation routing record (if RETURNED_WITH_ITEMS) | **REQUIRED** | BLOCKER — returned items have no addressable owner or target |

### Detailed Output Specifications

#### Decision record — schema

The decision record is a purpose-specific document. It is not a field appended to the bootstrap report — it is a separate, immutable record created at the moment of decision. Once created, it cannot be modified.

| Field | Type | Requirement | Format rule |
|---|---|---|---|
| `decision_id` | String | **REQUIRED** | Kebab-case; unique; e.g., `bootstrap-readiness-decision-[project_id]` |
| `project_id` | String | **REQUIRED** | Must match `project_id` in the approved manifest exactly |
| `decision` | Enum | **REQUIRED** | `APPROVED` or `RETURNED_WITH_ITEMS` |
| `decided_by` | String | **REQUIRED** | Name of `human:director` exactly as recorded in the manifest's `human_actors` list |
| `decided_at` | ISO 8601 datetime | **REQUIRED** | Timestamp of the moment the decision was recorded — with timezone |
| `report_version_reviewed` | String | **REQUIRED** | The `report_version` value from the bootstrap report reviewed; confirms which specific report this decision was based on |
| `report_verdict_at_decision` | Enum | **REQUIRED** | `PASS` or `PASS_WITH_GAPS` — the verdict of the report at the time of decision |
| `gap_acknowledgements` | List | Conditional | Required if `report_verdict_at_decision: PASS_WITH_GAPS`; one entry per non-blocking gap in the report gap list; see schema below |
| `approved_statement` | String | Conditional | Required if `decision: APPROVED`; one sentence in the first person acknowledging the decision and its irreversibility; not a template phrase — written by `human:director`; minimum 10 words |
| `returned_items` | List | Conditional | Required if `decision: RETURNED_WITH_ITEMS`; one entry per returned item; see schema below |
| `notes` | String | OPTIONAL | Any additional context `human:director` wants recorded; not required; may be empty |

#### Gap acknowledgement entry — schema

One entry per non-blocking gap in the report gap list. All entries must be present before `APPROVED` is available as a decision option.

| Field | Requirement | Format |
|---|---|---|
| `gap_id` | **REQUIRED** | The `gap_id` from the bootstrap report gap list entry being acknowledged |
| `gap_description` | **REQUIRED** | The gap description as written in the report — not paraphrased; confirms which gap is being acknowledged |
| `acknowledged` | **REQUIRED** | Must be `true` — a gap that is not acknowledged is not an informed proceeding decision; the decision record is invalid if any entry has `acknowledged: false` |
| `acknowledgement_note` | OPTIONAL | Any context `human:director` wants recorded about this specific gap — their plan for addressing it, their assessment of its impact, or their reason for accepting it |

#### Returned item entry — schema

One entry per item `human:director` is returning. Returned items may be either items from the gap list or items the human identified independently upon reviewing the report or underlying evidence.

| Field | Requirement | Format |
|---|---|---|
| `item_id` | **REQUIRED** | Sequential identifier, e.g., `RI-01`, `RI-02` |
| `description` | **REQUIRED** | What specifically is being returned — concrete enough that the party receiving it knows what to address without needing to ask a clarifying question |
| `source_step` | **REQUIRED** | Which step (1–5) produced the item being returned |
| `type` | **REQUIRED** | `REPORT_GAP` (an item from the bootstrap report gap list) or `DIRECTOR_FINDING` (an item identified by human:director independently of the report) |
| `remediation_instruction` | **REQUIRED** | What `human:director` wants done — specific enough to route to the right step for remediation |

***

## Definition of Done

### Summary

Step 6 is done when one of two terminal conditions is reached:

**Terminal condition A — APPROVED:**
1. The decision record exists at the canonical path with `decision: APPROVED`
2. `decided_by` matches a `human:director` entry in the manifest's `human_actors`
3. `decided_at` is a valid ISO 8601 datetime with timezone
4. `report_version_reviewed` matches the bootstrap report's `report_version`
5. If `PASS_WITH_GAPS`: every non-blocking gap has an acknowledgement entry with `acknowledged: true`
6. `approved_statement` is present, first-person, and at minimum 10 words
7. The bootstrap lifecycle state has transitioned to `CLOSED`
8. The decision record is immutable — it cannot be edited after creation

**Terminal condition B — RETURNED_WITH_ITEMS:**
1. The decision record exists with `decision: RETURNED_WITH_ITEMS`
2. `decided_by` and `decided_at` are present and valid
3. At least one returned item entry is present
4. Every returned item has a `description`, `source_step`, and `remediation_instruction`
5. Every returned item has been routed to the owning step with the remediation instruction attached
6. The routing record confirms receipt

### Unambiguous Requirement Breakdown

#### APPROVED — Condition 1: Decision record exists at canonical path

- The file exists at `[project-root]/.framework/bootstrap-decision.md`
- The file is non-empty
- `decision` field is `APPROVED`
- **Fails if:** File is absent; `decision` field is absent; field contains any value other than `APPROVED` or `RETURNED_WITH_ITEMS`

#### APPROVED — Condition 2: decided_by is a confirmed human:director

- `decided_by` contains a name
- That name matches — character for character — the `name` field of an entry in the manifest's `human_actors` list whose `role` is `human:director`
- **Fails if:** `decided_by` is empty; the name does not match any `human:director` entry in the manifest; the name matches a `human:approver` or other role that is not `human:director`

#### APPROVED — Condition 3: decided_at is valid

- `decided_at` is present
- Value is a valid ISO 8601 datetime
- Value includes a timezone offset or `Z`
- The timestamp is after the `generated_at` timestamp of the bootstrap report — a decision cannot predate the report it is based on
- **Fails if:** Field is absent; value is not valid ISO 8601; value lacks timezone; value is earlier than the report's `generated_at`

#### APPROVED — Condition 4: report_version_reviewed matches

- `report_version_reviewed` matches the `report_version` field in the bootstrap report
- **Fails if:** Field is absent; value does not match; value matches a prior draft version rather than the report produced at the end of Step 5

#### APPROVED — Condition 5: All gaps acknowledged (PASS_WITH_GAPS only)

- This condition only applies if `report_verdict_at_decision: PASS_WITH_GAPS`
- The number of gap acknowledgement entries equals the number of non-blocking gaps in the report gap list
- Every entry has `acknowledged: true`
- Every entry's `gap_description` matches the corresponding gap list entry from the report — not a paraphrase
- **Fails if:** Any non-blocking gap from the report has no acknowledgement entry; any entry has `acknowledged: false`; any entry's `gap_description` is a paraphrase rather than the exact text from the report; the entry count is less than the gap count

#### APPROVED — Condition 6: approved_statement is present and valid

- `approved_statement` is present
- It is written in the first person (begins with "I" or a first-person construction)
- It contains at least 10 words
- It is not a template phrase reproduced verbatim from the policy or toolkit — it is written by `human:director`
- **Fails if:** Field is absent or empty; statement is not first-person; fewer than 10 words; statement is a verbatim copy of any template text in the toolkit

#### APPROVED — Condition 7: Bootstrap lifecycle state is CLOSED

- The project's bootstrap lifecycle state is `CLOSED` in the Nexus system
- The state transition is recorded in the audit log with: the transition (`BOOTSTRAP_ACTIVE → CLOSED`), the actor identity (`human:director` name), and the timestamp
- **Fails if:** Lifecycle state is not `CLOSED`; the transition is not in the audit log; the audit entry does not attribute the transition to `human:director`

#### APPROVED — Condition 8: Decision record is immutable

- The decision record cannot be modified after the `APPROVED` decision is recorded
- Immutability is enforced by the system — it is not a matter of process discipline
- The audit log records the creation of the decision record; there are no subsequent write events for the same record
- **Fails if:** The decision record can be overwritten; the audit log shows a write event after the creation event for the same record; the record has a modification timestamp that differs from its creation timestamp

#### RETURNED — Condition 1–6: Returned items are specific and routed

- Every returned item has all required fields non-empty
- `description` is specific enough to be actionable without clarification — "fix the environment contract" is not specific; "the `deployment.build_command` in the environment contract contradicts the `framework.output_mode`; these must be reconciled" is specific
- Every item has been routed to the owning step: the relevant step's policy owner has received the `remediation_instruction` and confirmed receipt
- The routing record identifies: the item ID, the source step, the routing target, the timestamp of routing, and the confirmation of receipt
- **Fails if:** Any item has empty `description` or `remediation_instruction`; any item has not been routed; any routing has no confirmation of receipt

***

## Tasks

***

### Task 6.1 — Readiness Package Assembly

**Question:** Does `human:director` have everything they need to make a genuinely informed decision?

**Input:** `bootstrap-report.md` with `PASS` or `PASS_WITH_GAPS` verdict; links to all prior step outputs and verification records; decision record template; gap acknowledgement prompts (one per non-blocking gap if `PASS_WITH_GAPS`)

**Output:** Readiness package delivered to `human:director` — structured presentation of the report, navigation index, gap acknowledgement prompts if applicable, and decision prompt

**Subtasks:**
- Confirm the bootstrap report verdict is `PASS` or `PASS_WITH_GAPS` before assembling the package — if `FAIL`, do not assemble; return to Step 5
- Confirm all prior step outputs are accessible at their canonical paths — if any are missing, do not assemble; flag the missing output before proceeding
- Assemble the navigation index: one entry per prior step output and its verification record, with canonical path
- If `PASS_WITH_GAPS`: extract the gap list from the report; create one acknowledgement prompt per gap, each containing the gap ID, the exact gap description from the report, and a binary acknowledgement field
- Compose the decision prompt: state explicitly that `human:director` is being asked to decide whether the project is ready for delivery, that `APPROVED` is irreversible, that any gap acknowledgements must be completed before `APPROVED` is available, and that `RETURNED_WITH_ITEMS` is available at any point
- Deliver the package to `human:director` through the project's established communication channel
- Record the delivery: timestamp, delivery channel, and confirmation that the package was received

**Done when:** Package delivered; delivery recorded with timestamp; receipt confirmed by `human:director` or delivery mechanism

***

### Task 6.2 — Human Review

**Primary actor:** `human:director`

**Question:** Having reviewed the bootstrap report and all evidence accessible to me, am I willing to begin delivery?

**This task describes what `human:director` must do — it does not dictate what they must conclude.**

**What must be reviewed:**
- The bootstrap report in full — not the readiness package summary, the full report
- The gap list, if present — every gap entry, not a count
- At minimum one item of underlying evidence per check section — the human must have accessed the primary documents, not relied solely on the report's assertions. This is confirmed through the navigation index access log

**What must be completed before deciding APPROVED:**
- Every gap acknowledgement prompt must be filled with `acknowledged: true` — a gap may not be silently skipped
- The `approved_statement` must be composed — the human writes this; it is not pre-filled

**What may be done at any point before deciding:**
- Navigate to any underlying evidence using the navigation index
- Request clarification on any report item — routed to the relevant step owner; the decision is paused until clarification is received
- Decide to return specific items without reviewing the full report — `RETURNED_WITH_ITEMS` is available from the moment the package is received

**What `human:director` must not do:**
- Approve without completing all gap acknowledgements (if `PASS_WITH_GAPS`) — the system prevents this
- Delegate the `APPROVED` decision to another party — this decision belongs to the `human:director` role specifically. It may not be made by `human:approver` or any other party

**Done when:** `human:director` has submitted either an `APPROVED` decision with all required fields, or a `RETURNED_WITH_ITEMS` decision with at least one returned item

***

### Task 6.3 — Decision Recording

**Question:** Is the decision record complete, valid, and immutable?

**Input:** `human:director`'s decision submission; decision record template; gap acknowledgements (if PASS_WITH_GAPS)

**Output:** `bootstrap-decision.md` at the canonical path; audit log entry for the decision; bootstrap lifecycle state transition (if APPROVED)

**Subtasks (APPROVED path):**
- Populate every required field in the decision record from `human:director`'s submission
- Validate each field against the DoD requirements before writing:
  - `decided_by` matches a `human:director` entry in the manifest — if not, the submission cannot be accepted
  - `decided_at` is after the bootstrap report's `generated_at` — if not, the timestamp is invalid
  - `report_version_reviewed` matches the current report — if not, the wrong report was reviewed
  - All gap acknowledgements are present and have `acknowledged: true` — if any are missing or false, block the record and return to Task 6.2
  - `approved_statement` is present, first-person, minimum 10 words, not a template phrase — if not, return to Task 6.2
- Write the decision record to `[project-root]/.framework/bootstrap-decision.md`
- Apply immutability: lock the record against future writes — the mechanism for this is system-level, not policy-level (see F26)
- Write audit log entry: action type `bootstrap_approved`, actor identity `decided_by` value, timestamp `decided_at` value, task reference `bootstrap-[project_id]`
- Trigger the bootstrap lifecycle state transition: `BOOTSTRAP_ACTIVE → CLOSED`
- Confirm the state transition is in the audit log with correct attribution

**Subtasks (RETURNED_WITH_ITEMS path):**
- Populate every required field in the decision record
- Validate that every returned item has a specific `description` and `remediation_instruction`
- Write the decision record to the canonical path
- Write audit log entry: action type `bootstrap_returned`, actor identity, timestamp, returned item count
- Proceed to Task 6.4 for routing

**Done when (APPROVED):** Decision record written and immutable; audit log entry present; bootstrap lifecycle state is `CLOSED`

**Done when (RETURNED):** Decision record written; audit log entry present; Task 6.4 can proceed

***

### Task 6.4 — Post-Decision Routing

**Two paths — one per decision outcome.**

***

#### Path A: APPROVED

**Question:** Is the system in a clean, confirmed-ready state for the first delivery task?

**Input:** Bootstrap lifecycle state `CLOSED`; decision record `APPROVED`; all prior step outputs at canonical paths

**Output:** Delivery readiness confirmation — a brief structured record confirming the system state at the moment delivery opens

**Subtasks:**
- Confirm bootstrap lifecycle state is `CLOSED` in the Nexus system
- Confirm the pattern library is accessible and returns results for a query against a domain tag present in the `PROVISIONAL` set — the knowledge base must be queryable, not just populated
- Confirm role definitions are accessible at their canonical paths
- Confirm the audit log is operational — it has been continuously recording since the smoke test; check for any gap since the smoke test task was cancelled
- Produce the delivery readiness confirmation: project ID, `BOOTSTRAP_CLOSED` state, timestamp, decision record reference, pattern count, role count, a single statement that delivery work may begin
- File the confirmation at `[project-root]/.framework/delivery-readiness.md`

**Done when:** Delivery readiness confirmation is filed; all four system state checks passed; the project is in a state where the first delivery task can be created

***

#### Path B: RETURNED_WITH_ITEMS

**Question:** Has every returned item been routed to the correct step with a clear remediation instruction?

**Input:** Decision record with `returned_items` list

**Output:** Routing record — one entry per returned item confirming it was received by the owning step

**Subtasks:**
- For each returned item: identify the owning step from `source_step`
- Route the item to the owning step's process with the `remediation_instruction` attached — the routing is a formal hand-off, not a notification
- For each item: confirm receipt — the owning step confirms it has received the item and understands the remediation instruction
- Record the routing: item ID, source step, routing target, timestamp, receipt confirmation
- After all items are routed: the bootstrapping phase re-enters the relevant steps for remediation; Step 6 suspends until the remediated steps produce new outputs and Step 5 produces a new bootstrap report
- Note: when Step 5 produces a new `PASS` or `PASS_WITH_GAPS` report after remediation, Step 6 begins again from Task 6.1 — it does not resume mid-step

**Done when:** Every returned item is routed with receipt confirmed; routing record is filed with all timestamps; the bootstrapping phase status reflects that it is awaiting remediation, not that Step 6 is complete

***

## Items to Flag for Higher-Level Consideration

**F26 — Immutability as a System Mechanism**
Task 6.3 requires the decision record to be immutable after creation. Policy can state this requirement but cannot enforce it — enforcement requires a system-level mechanism. The options include: write-once file permissions set at creation, a hash of the record stored in the audit log (any modification changes the hash), or the Nexus server's write tool refusing to overwrite a record in `CLOSED` state. Which mechanism is used — and how immutability is independently verifiable — belongs at framework level.

**F27 — The RETURNED_WITH_ITEMS Loop Limit**
A `RETURNED_WITH_ITEMS` decision routes items back to prior steps, which then produce new outputs, which Step 5 re-verifies, which Step 6 reviews again. In theory this loop has no upper bound. In practice, a project that reaches Step 6 three times without an `APPROVED` decision is signalling a structural problem — either the prior steps have a persistent issue, or `human:director`'s requirements are unclear. A maximum return count, and what happens when it is reached, belongs at framework level.

**F28 — The Notification and Timing Protocol**
Step 6 begins when `human:director` receives the readiness package. But the policy does not define: how `human:director` is notified that the package is ready, what the expected response window is, or what happens if `human:director` is unavailable. A bootstrap that completes Steps 1–5 but cannot reach `human:director` for three days is not a bootstrap that is progressing. A response time expectation — and an escalation path if it is not met — belongs at framework level.

**F29 — Gap Acknowledgement as Evidence of Understanding**
The policy requires `human:director` to acknowledge each non-blocking gap with `acknowledged: true`. This proves the gap was presented — it does not prove it was understood. An acknowledgement that takes 0.3 seconds per gap is not evidence of understanding. Whether to require an `acknowledgement_note` (currently OPTIONAL) for gaps above a certain severity, or to require a minimum time between package delivery and decision, or to require the human to navigate to the underlying evidence for each gap before acknowledging it — these are evidence quality decisions that belong at framework level.

**F30 — Delegation and Substitution**
The policy states the `APPROVED` decision cannot be delegated — it belongs to `human:director`. But it does not address what happens if `human:director` becomes unavailable permanently or temporarily between Steps 5 and 6. Can another human assume the `human:director` role? Does that require an amendment to the manifest? Does it require a new Step 1? The substitution protocol for the `human:director` role at a one-way decision point belongs at framework level.

**F31 — The Bootstrap Lifecycle State Machine**
The `BOOTSTRAP_ACTIVE → CLOSED` transition is referenced in this policy but not defined. There is an implicit bootstrap lifecycle state machine: at minimum, states of `NOT_STARTED`, `IN_PROGRESS`, `AWAITING_DECISION`, `AWAITING_REMEDIATION`, and `CLOSED`. The complete state machine — states, valid transitions, transition triggers, and terminal conditions — belongs at framework level and should be formally defined before this policy is implemented.
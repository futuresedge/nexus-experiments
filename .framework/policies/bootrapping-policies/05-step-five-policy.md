# Step 5 Policy: End-to-End Verification

**Version:** 0.1 — Draft
**Depends on:** Steps 1–4 all complete — all four outputs in their accepted states simultaneously
**Blocks:** Step 6 (Human Readiness Confirmation) cannot begin until the bootstrap report is produced with a verdict

***

## Overview

Step 5 answers one question: *Does the system actually work — not in theory, but in practice?*

Steps 1 through 4 each produced verified outputs in isolation. Step 5 is the first time all of those outputs are consumed together as a functioning system. This is a categorically different kind of verification — individual correctness is necessary but not sufficient. A system of individually verified components can still fail when the components are connected. This step finds that class of failure before delivery begins.

Step 5 has three distinct checks that must all pass:

**Document verification:** Every output from Steps 1–4 exists, is in the correct state, and its verification records are present. This is the fastest check. It confirms that the prior steps actually completed — it does not re-verify the quality of their outputs, which is already on record.

**Infrastructure verification:** Every system component required to support delivery is operational. Not "installed" — operational. Each component is exercised in a way that produces observable, recordable evidence of function. A component that is installed but not responding is not operational.

**Smoke test:** A minimal unit of work is run through the complete process lifecycle — from creation to cancellation, passing through every intermediate state. Every action in the smoke test must produce an audit record. The audit log is then inspected for completeness: no action without a record, no record without an attributed actor. The smoke test does not execute delivery work — it exercises the system's ability to receive, prepare, and manage a unit of work up to the point of execution.

The bootstrap report produced by this step is the evidence package for Step 6. Step 6 is a human decision — this step produces the evidence that decision is based on.

***

## Inputs

### Summary

| Input | Source | Requirement | If Absent |
|---|---|---|---|
| `project-manifest.md` in `APPROVED` status | Step 1 | **REQUIRED** | Hard blocker |
| `environment-contract.md` in `ACCEPTED` status | Step 2 | **REQUIRED** | Hard blocker |
| All roster role definitions at canonical paths | Step 3 | **REQUIRED** | Hard blocker |
| Individual verification records for all roles | Step 3 | **REQUIRED** | Hard blocker |
| Set verification record | Step 3 | **REQUIRED** | Hard blocker |
| `context-tree.md` | Step 3 | **REQUIRED** | Hard blocker |
| `PROVISIONAL` patterns (≥ 5) | Step 4 | **REQUIRED** | Hard blocker |
| Domain coverage map | Step 4 | **REQUIRED** | Hard blocker |
| Pattern review records for all `PROVISIONAL` patterns | Step 4 | **REQUIRED** | Hard blocker |
| Live system infrastructure (Nexus MCP server, audit log, observable stream, policy engine) | System | **REQUIRED** | Hard blocker — infrastructure checks and smoke test cannot run |
| Bootstrap report template | Toolkit | **REQUIRED** | No schema to structure the report against |

### Detailed Input Specifications

#### Prior step outputs — general requirement

All four prior step outputs must be in their accepted states **simultaneously** when Step 5 begins. A Step 5 that begins while Step 3 is still in progress is not valid — partial completion of Step 3 while Step 5 is running means the document verification check is operating on an incomplete state.

| Prior step output | Accepted state required |
|---|---|
| `project-manifest.md` | `status: APPROVED` |
| `environment-contract.md` | `review_status: ACCEPTED` |
| All role definitions | Each at canonical path, individually verified `PASS ALL`, set verification `PASS` |
| Pattern library | ≥ 5 entries with `status: PROVISIONAL`; at least one with `verification` domain tag |

#### Live system infrastructure

| Component | What "present" means | What "operational" means |
|---|---|---|
| Nexus MCP server | Running process, listening on configured port | Responds to a universal tool call with a valid, structured response |
| Audit log (SQLite) | Database file exists, schema applied | Accepts a write operation; written entry is readable back with correct attribution and timestamp |
| Observable stream | Stream service running | Accepts an emitted event; event appears in the stream with correct payload and timestamp |
| Policy engine | Service running | Accepts a valid state transition request and executes it; rejects an invalid state transition request with a rejection reason |
| Context card service | Service running | Returns a valid, schema-conformant context card when queried for a known role class in the confirmed roster |
| Knowledge base search | Service running | Returns results when queried for a domain tag present in the `PROVISIONAL` pattern set |

***

## Outputs

### Summary

| Output | Requirement | If Absent or Incomplete |
|---|---|---|
| `bootstrap-report.md` with a verdict | **REQUIRED** | BLOCKER — Step 6 has no evidence to review |
| Document check results (all 8 items) with evidence | **REQUIRED** | BLOCKER — document verification is incomplete |
| Infrastructure check results (all 6 components) with evidence | **REQUIRED** | BLOCKER — infrastructure verification is incomplete |
| Smoke test results (all 8 steps) with evidence | **REQUIRED** | BLOCKER — end-to-end verification is incomplete |
| Audit log completeness record | **REQUIRED** | BLOCKER — T4 compliance cannot be confirmed |
| Gap list (if verdict is not `PASS`) | Conditional | Required for `PASS_WITH_GAPS` and `FAIL` verdicts; Step 6 needs it |

### Detailed Output Specifications

#### `bootstrap-report.md` — schema

Every section and field below must be present. Required fields must be non-empty.

**Report header:**

| Field | Type | Requirement | Format rule |
|---|---|---|---|
| `project_id` | String | **REQUIRED** | Must match `project_id` in the approved manifest exactly |
| `report_version` | String | **REQUIRED** | `1.0` on first production |
| `generated_at` | ISO 8601 datetime | **REQUIRED** | Timestamp of report production completion |
| `generated_by` | String | **REQUIRED** | Identity of the party that produced the report; must differ from parties that produced Steps 1–4 outputs |
| `verdict` | Enum | **REQUIRED** | `PASS` \| `PASS_WITH_GAPS` \| `FAIL` — see verdict definitions below |

**Verdict definitions:**

| Verdict | Conditions |
|---|---|
| `PASS` | All document checks pass; all infrastructure checks pass; all smoke test steps pass; audit log has no gaps |
| `PASS_WITH_GAPS` | All blocking conditions pass; all smoke test steps pass; audit log has no gaps; but one or more non-blocking gaps are present (e.g., unseeded domains from Step 4, unresolved optional open questions from Steps 1–2) |
| `FAIL` | Any blocking document check fails; OR any infrastructure component is non-operational; OR any smoke test step fails; OR the audit log has any gap |

`PASS_WITH_GAPS` is a valid verdict for Step 6 — `human:director` makes an informed decision with documented gaps. `FAIL` must be resolved before Step 6 can proceed — a `FAIL` report is returned with specific remediation items; the relevant step is revisited; Step 5 runs again.

**Document checks section** — one entry per checked item:

| Field per entry | Requirement | Format |
|---|---|---|
| `item` | **REQUIRED** | The document or record being checked |
| `check` | **REQUIRED** | What specifically is being confirmed — not "exists and is valid" but the specific condition |
| `result` | **REQUIRED** | `PASS` or `FAIL` |
| `evidence` | **REQUIRED** | Literal reference to what was observed — file path and status field value, verification record location and verdict, count of entries — not an assertion |
| `classification` | **REQUIRED** | `BLOCKING` (a `FAIL` here produces a report `FAIL` verdict) or `NON_BLOCKING` (a `FAIL` here produces a `PASS_WITH_GAPS` verdict) |

**Infrastructure checks section** — one entry per component:

| Field per entry | Requirement | Format |
|---|---|---|
| `component` | **REQUIRED** | The system component being verified |
| `test_performed` | **REQUIRED** | The specific operation performed to test this component — the actual tool call or command issued |
| `expected_result` | **REQUIRED** | What a functioning component produces in response |
| `actual_result` | **REQUIRED** | What was actually observed — verbatim where possible |
| `result` | **REQUIRED** | `OPERATIONAL` or `NON_OPERATIONAL` |
| `classification` | **REQUIRED** | `BLOCKING` for all infrastructure checks — a non-operational component produces a `FAIL` verdict |

**Smoke test results section** — one entry per smoke test step:

| Field per entry | Requirement | Format |
|---|---|---|
| `step` | **REQUIRED** | The step identifier and description |
| `action_taken` | **REQUIRED** | What was done — the specific call or operation performed |
| `expected_state` | **REQUIRED** | The system state or audit entry expected after this action |
| `actual_state` | **REQUIRED** | What was actually observed |
| `result` | **REQUIRED** | `PASS` or `FAIL` |
| `audit_entry_id` | **REQUIRED** | The identifier of the audit log entry produced by this action |
| `classification` | **REQUIRED** | `BLOCKING` for all smoke test steps — any failure produces a `FAIL` verdict |

**Audit log completeness record:**

| Field | Requirement | Format |
|---|---|---|
| `total_smoke_test_actions` | **REQUIRED** | Count of actions performed during the smoke test |
| `audit_entries_found` | **REQUIRED** | Count of audit entries found corresponding to smoke test actions |
| `gap_count` | **REQUIRED** | Number of actions with no corresponding audit entry (must be 0 for PASS) |
| `gap_details` | Conditional | Required if `gap_count > 0`; one entry per gap with the action and the missing entry description |
| `result` | **REQUIRED** | `COMPLETE` (gap_count = 0) or `INCOMPLETE` |

**Gap list** — required if verdict is `PASS_WITH_GAPS` or `FAIL`:

| Field per entry | Requirement | Format |
|---|---|---|
| `gap_id` | **REQUIRED** | Sequential identifier, e.g., `GAP-01` |
| `source_step` | **REQUIRED** | Which step (1–5) the gap originates from |
| `description` | **REQUIRED** | Specific description of what is missing or failed |
| `classification` | **REQUIRED** | `BLOCKING` (must be resolved before Step 6) or `NON_BLOCKING` (noted; human:director decides in Step 6) |
| `remediation` | **REQUIRED** for `BLOCKING` | Which step must be revisited and what specifically must be corrected |

***

## Definition of Done

### Summary

Step 5 is done when all seven conditions are simultaneously true:

1. `bootstrap-report.md` exists at the canonical path with a declared verdict
2. All 8 document check items are present in the report with evidence
3. All 6 infrastructure components have been tested and results recorded
4. All 8 smoke test steps were executed and results recorded
5. The audit log completeness check shows `gap_count: 0` for the smoke test
6. If the verdict is `PASS_WITH_GAPS` or `FAIL`, a gap list is present with classifications and remediations for all `BLOCKING` gaps
7. The report was produced by a party that did not produce any of the Steps 1–4 outputs it verifies

### Unambiguous Requirement Breakdown

#### DoD 1 — Bootstrap report exists with a verdict

- The file exists at `[project-root]/.framework/bootstrap-report.md`
- The `verdict` field is present and contains exactly one of: `PASS`, `PASS_WITH_GAPS`, `FAIL`
- `generated_at` is a valid ISO 8601 datetime
- `generated_by` is present and non-empty
- **Fails if:** File is absent; `verdict` field is absent or contains any other value; `generated_at` is absent; `generated_by` is absent

#### DoD 2 — All document check items present with evidence

- The document checks section contains exactly 8 entries, one per item in the document check list (see Task 5.1)
- Every entry has a non-empty `evidence` field with a specific reference — not an assertion
- A `PASS` result with no evidence is not a passing result
- **Fails if:** Fewer than 8 check entries; any entry has an empty or non-specific `evidence` field; any entry is missing a `result` or `classification` field

#### DoD 3 — All 6 infrastructure components tested

- The infrastructure checks section contains exactly 6 entries, one per component (see Task 5.2)
- Every entry has a non-empty `test_performed` field describing the actual operation conducted
- Every entry has a non-empty `actual_result` field describing what was observed — not what was expected
- **Fails if:** Fewer than 6 check entries; any entry has an empty `test_performed` or `actual_result`; any entry has `expected_result` duplicated as `actual_result` without independent observation

#### DoD 4 — All 8 smoke test steps executed and recorded

- The smoke test results section contains exactly 8 entries, one per step in the smoke test sequence (see Task 5.3)
- Every entry has a non-empty `action_taken` and `actual_state` field
- Every entry has a non-empty `audit_entry_id` referencing a specific audit log entry
- The smoke test task (`smoke-01`) is in `CANCELLED` state after the smoke test completes
- **Fails if:** Fewer than 8 smoke test entries; any entry has an empty `audit_entry_id`; the smoke test task is not cancelled after test completion; any step shows `FAIL`

#### DoD 5 — Audit log completeness: gap_count = 0

- `total_smoke_test_actions` equals the number of actions in the smoke test sequence (8)
- `audit_entries_found` equals `total_smoke_test_actions`
- `gap_count` is exactly 0
- `result` is `COMPLETE`
- **Fails if:** `gap_count` is any value other than 0; `audit_entries_found` does not equal `total_smoke_test_actions`; the completeness record is absent

#### DoD 6 — Gap list present and complete for non-PASS verdicts

- If `verdict: PASS`: gap list may be absent or empty — this condition is satisfied
- If `verdict: PASS_WITH_GAPS`: gap list must be present; every non-blocking gap must have an entry; `gap_count > 0`
- If `verdict: FAIL`: gap list must be present; every blocking gap must have a `remediation` entry specifying which step to revisit and what to correct
- **Fails if:** Verdict is `PASS_WITH_GAPS` or `FAIL` and no gap list is present; any `BLOCKING` gap has no `remediation`; any gap entry is missing a `classification`

#### DoD 7 — Producer independence

- `generated_by` in the report identifies a party that did not produce any of the following:
  - `project-manifest.md`
  - `environment-contract.md`
  - Any role definition in the confirmed roster
  - Any `PROVISIONAL` pattern entry
- This is structural — the same party cannot act as both producer and verifier even at different times
- **Fails if:** `generated_by` matches the producer of any Steps 1–4 output; the independence claim is unverifiable because producer identities from prior steps are not on record

***

## Tasks

***

### Task 5.1 — Document Verification

**Question:** Are all Step 1–4 outputs present, in their accepted states, and supported by their verification records?

**Input:** All prior step outputs; prior step verification records; bootstrap report template (document checks section)

**Output:** Completed document checks section of the bootstrap report — 8 entries with evidence and verdicts

**The 8 document check items:**

| # | Item | Specific check | Classification |
|---|---|---|---|
| D1 | `project-manifest.md` | File exists; `status: APPROVED`; `approved_at` present; `approved_by` matches a `human:director` entry | BLOCKING |
| D2 | `environment-contract.md` | File exists; `review_status: ACCEPTED`; `reviewed_by` present; `contract_version` present | BLOCKING |
| D3 | Role definitions — completeness | One definition file exists per class in the confirmed roster; all at canonical paths; no extraneous files | BLOCKING |
| D4 | Role definitions — individual verification | One verification record exists per role class; all records show `PASS ALL` verdict; all records have reviewer identity and timestamp | BLOCKING |
| D5 | Role definitions — set verification | Set verification record exists; verdict is `PASS`; verifier identity present and differs from definition producer | BLOCKING |
| D6 | Context tree | `context-tree.md` exists; write authority map present; all required document types from taxonomy are listed | BLOCKING |
| D7 | Pattern library minimum | Count of `PROVISIONAL` patterns is ≥ 5; at least one carries `verification` domain tag | BLOCKING |
| D8 | Domain coverage map | `seed-coverage.md` exists; every unseeded domain has a documented rationale | NON-BLOCKING |

**Subtasks:**
- For each check item: perform the specific check as stated — do not perform a more general check and infer
- For each `PASS` result: record the specific evidence that confirms it (file path, field value, record location, count) — not "file exists and looks correct"
- For each `FAIL` result: record exactly what was missing or incorrect
- If any `BLOCKING` item fails: flag immediately — the report verdict will be `FAIL` regardless of subsequent checks; continue completing all checks to produce a complete gap list

**Done when:** All 8 check entries are complete with specific evidence; no entry has an empty evidence field

***

### Task 5.2 — Infrastructure Verification

**Question:** Is every system component required for delivery operational?

**Input:** Live system infrastructure; bootstrap report template (infrastructure checks section)

**Output:** Completed infrastructure checks section — 6 entries with test performed, expected result, actual result, and verdict

**The 6 infrastructure component tests:**

| # | Component | Test to perform | Expected result |
|---|---|---|---|
| I1 | Nexus MCP server | Call `get_my_capabilities` (a universal tool) | Returns a structured list of capabilities; response is valid JSON conformant to the tool's response schema |
| I2 | Audit log (SQLite) | Write a labelled test entry (`audit_test: bootstrap-step-5`); immediately read it back by its ID | Read-back returns the exact entry written with correct attribution and timestamp; no data loss |
| I3 | Observable stream | Emit a labelled test event (`stream_test: bootstrap-step-5`) | Event appears in the stream with the correct payload, source attribution, and timestamp within the observable window |
| I4 | Policy engine — valid transition | Submit a valid state transition request for the smoke test task (see Task 5.3 for the specific transition) | Transition executes; task state changes; audit entry is written |
| I5 | Policy engine — invalid transition | Submit an invalid state transition request (attempt to transition `smoke-01` from `DRAFT` directly to `CONTEXT_READY`, skipping required intermediate states) | Request is rejected with a rejection reason; task state is unchanged; rejection is audited |
| I6 | Context card service | Request a context card for a role class in the confirmed roster | Returns a schema-conformant context card with the requested role's data populated; response is not empty |

**Subtasks:**
- Perform each test in sequence — do not parallelise tests that share state (I4 and I5 both involve the smoke test task)
- Record `actual_result` as observed — do not record the expected result as the actual result without independent observation
- For I2: the read-back must be performed as a separate operation from the write — not a confirmation that the write API returned success
- For I5: confirm the rejection reason is present and meaningful — an empty rejection reason does not satisfy this check
- If any component returns `NON_OPERATIONAL`: record the observed failure mode; flag for the gap list

**Done when:** All 6 infrastructure entries are complete; `actual_result` is independently observed for each; no entry conflates expected with actual

***

### Task 5.3 — Smoke Test Execution

**Question:** Can a unit of work be created, specified, prepared for execution, and cancelled cleanly — with every action producing an audit record?

**Input:** Operational system infrastructure (confirmed in Task 5.2); confirmed role roster (from Step 3)

**Output:** Completed smoke test results section — 8 entries; smoke test task `smoke-01` in `CANCELLED` state; audit entries for all 8 actions

**Smoke test sequence:**

| Step | Action | Expected system state after action | Audit entry expected |
|---|---|---|---|
| S1 | Create test task: `smoke-01` with a minimal, clearly labelled description ("Bootstrap smoke test — not real work. Cancel after test.") | Task exists; `state: DRAFT` | `task_created: smoke-01` |
| S2 | Write task specification for `smoke-01`: a minimal, explicitly labelled spec ("Smoke test spec. This task will not be executed.") | Task spec exists for `smoke-01` | `task_spec_written: smoke-01` |
| S3 | Write proof template for `smoke-01` from a different party than wrote the spec: a minimal template stating what proof would look like for a real task of this type | Proof template exists for `smoke-01`; producing party differs from spec writer — confirmed in audit log | `proof_template_written: smoke-01`; producing party identity recorded |
| S4 | Submit task spec for `smoke-01` → policy engine evaluates transition | Task state transitions from `DRAFT` to `SPEC_APPROVED`; policy engine accepted the transition | `state_transitioned: smoke-01 DRAFT→SPEC_APPROVED` |
| S5 | Context card service generates context cards for `smoke-01` for all required roles | Context cards exist for `smoke-01`; one per role in the confirmed roster that participates in the work lifecycle | `context_cards_generated: smoke-01`; count of cards matches expected role count |
| S6 | Submit context ready for `smoke-01` → policy engine evaluates transition | Task state transitions from `SPEC_APPROVED` to `CONTEXT_READY`; policy engine accepted the transition | `state_transitioned: smoke-01 SPEC_APPROVED→CONTEXT_READY` |
| S7 | Cancel `smoke-01` | Task state transitions to `CANCELLED`; no further transitions possible | `task_cancelled: smoke-01` |
| S8 | Confirm cancellation audit entry exists and is correctly attributed | Audit log contains the cancellation entry; entry has actor identity, timestamp, and reason | Confirmed by reading back the audit entry from Task 5.4 |

**Critical constraints on smoke test execution:**

- The smoke test task **must not** transition to `IN_PROGRESS` — the purpose is to prove the system can receive and prepare work, not to execute it
- The proof template written in S3 must be produced by a structurally different party from the spec writer in S2 — this tests the T5 enforcement mechanism, not just the state machine
- S5 must produce at minimum one valid context card — if the context card service returns an empty or invalid card, S5 fails regardless of the state transition succeeding
- S7 must occur — an uncancelled smoke test task is a data hygiene problem for the project's work management system
- S8 must confirm the cancellation is in the audit log before the smoke test is considered complete — the audit log is the system of record, not the task's state field

**Done when:** All 8 steps executed; all 8 `audit_entry_id` fields are populated with real entry identifiers; `smoke-01` is in `CANCELLED` state; S3's audit entry confirms two different parties produced the spec and the proof template

***

### Task 5.4 — Audit Log Completeness Verification

**Question:** Does every action in the smoke test have a corresponding, attributed audit entry?

**Input:** Audit log; 8 `audit_entry_id` values from Task 5.3

**Output:** Audit log completeness record — gap count, entries found, gap details if any

**Subtasks:**
- For each of the 8 smoke test steps: retrieve the audit entry by its `audit_entry_id`
- For each retrieved entry: confirm it contains — the action type, the actor identity, the timestamp (ISO 8601 with timezone), the task identifier (`smoke-01`), and the resulting state
- If any `audit_entry_id` returns no entry: record as a gap
- If any retrieved entry is missing any required field: record as a partial gap — the entry exists but is incomplete
- Count: total actions = 8; entries found = count of fully complete entries; gaps = 8 minus entries found
- Record: `gap_count`, `audit_entries_found`, `result` (`COMPLETE` if gap_count = 0, `INCOMPLETE` otherwise)
- For any gap: record which step it corresponds to and what is missing

**Done when:** All 8 entries have been retrieved and inspected; completeness record is complete; if gap_count > 0, gap details are present for each gap

***

### Task 5.5 — Report Compilation and Verdict

**Question:** What is the overall verdict, and does the bootstrap report contain complete, navigable evidence?

**Input:** Document checks (Task 5.1); infrastructure checks (Task 5.2); smoke test results (Task 5.3); audit log completeness record (Task 5.4)

**Output:** Complete `bootstrap-report.md` with verdict and gap list

**Verdict determination — apply in order:**

1. If any document check item with `classification: BLOCKING` has `result: FAIL` → verdict is `FAIL`
2. If any infrastructure component has `result: NON_OPERATIONAL` → verdict is `FAIL`
3. If any smoke test step has `result: FAIL` → verdict is `FAIL`
4. If the audit log completeness record shows `result: INCOMPLETE` → verdict is `FAIL`
5. If none of the above apply but any non-blocking document check has `result: FAIL` → verdict is `PASS_WITH_GAPS`
6. If none of the above apply → verdict is `PASS`

**Gap list construction (required for `PASS_WITH_GAPS` and `FAIL`):**
- For every `FAIL` result in any section: create a gap entry
- Assign `GAP-01`, `GAP-02`, etc. in order of source step
- For `BLOCKING` gaps: include `remediation` specifying which step to revisit and the specific issue to address
- For `NON_BLOCKING` gaps: include a description; no remediation required — `human:director` decides in Step 6

**Subtasks:**
- Assemble all four check sections into the report template
- Determine verdict using the decision order above
- If `FAIL`: produce the gap list; do not proceed to Step 6 — return gap list to the relevant step owners; await remediation; Step 5 runs again after remediation
- If `PASS` or `PASS_WITH_GAPS`: complete the report; set `generated_at`, `generated_by`, `verdict`; save to `[project-root]/.framework/bootstrap-report.md`

**Done when:** Report is complete at canonical path; verdict is set; gap list is present if required; report is ready for Step 6 review

***

## Items to Flag for Higher-Level Consideration

**F20 — Audit Log Completeness as an Invariant**
The requirement that every action has an audit entry is not specific to the smoke test — it must hold for all delivery work throughout the project. What is checked in Task 5.4 for the smoke test must be enforced continuously during delivery. The mechanism for ongoing audit log integrity monitoring — who checks it, how often, what triggers an alert — belongs at framework level.

**F21 — The Smoke Test Scope Boundary**
The smoke test stops at `CONTEXT_READY` and does not enter execution. This decision means the smoke test does not exercise: the execution role receiving and acting on a context card, the proof submission mechanism, the review activation and verdict, or the approval gate. These are the most complex parts of the delivery lifecycle and are left untested by bootstrap. A richer smoke test that proceeds through execution and review would provide stronger verification but requires either dummy work output or a special "smoke test mode" for execution roles. This trade-off belongs at framework level.

**F22 — Producer Independence Across Multiple Steps**
Step 5's verifier must be independent of all Steps 1–4 output producers. In practice, the set of parties who could satisfy this constraint may be very small — especially in a small project where `human:director` was involved in Steps 1, 5, and 6. How the framework handles the independence constraint when the pool of independent parties is limited belongs at framework level.

**F23 — The PASS_WITH_GAPS Threshold**
The policy defines `PASS_WITH_GAPS` as a valid verdict for Step 6, meaning `human:director` can choose to proceed despite known non-blocking gaps. But the policy does not define an upper limit on non-blocking gaps beyond which the verdict should be `FAIL`. Is a bootstrap report with 15 non-blocking gaps genuinely acceptable for delivery to begin? A threshold — perhaps expressed as a fraction of domain coverage, or a specific prohibited gap type — belongs at framework level.

**F24 — The Smoke Test as a Living Test Suite**
The 8-step smoke test sequence is defined here for the bootstrap phase. As the framework evolves — new state transitions, new role types, new lifecycle stages — the smoke test must evolve with it. The governance of smoke test versioning (what triggers a revision, who approves it, whether prior bootstrap certificates remain valid after a test revision) belongs at framework level.

**F25 — Re-run Scope After a FAIL**
A `FAIL` verdict returns specific steps for remediation and then requires Step 5 to run again. But does the full Step 5 run again, or only the checks relevant to the remediated items? A full re-run is safe but potentially expensive. A targeted re-run is efficient but requires a policy for which checks are affected by which remediations. The re-run scope policy belongs at framework level.
Here is the policy document for Step 1. I'll flag items that sit above the steps at the end.

***

# Step 1 Policy: Project Intent Capture
**Version:** 0.1 — Draft
**Depends on:** None — this is the first step
**Blocks:** Step 2 (Environment Specification) cannot begin until this step's output is in `APPROVED` status

***

## Overview

Step 1 answers one question: *Is the project intent clear, complete, and consistent enough to structure?*

A human provides a description of a project they want to build. That description can arrive in any form. This step receives it, structures it into a machine-readable record, surfaces any gaps or conflicts, and gets the same human to confirm the record accurately represents their intent.

The output of this step is not an interpretation or an enhancement of the brief — it is a faithful restatement. If the human said it, it belongs. If they didn't say it, it goes in the record only as an open question. **Nothing is invented.**

This step has exactly two irreversible points: the moment the record is submitted for human review, and the moment the human approves it. Both are on record.

***

## Inputs

### Summary

| Input | Source | Requirement | If Absent |
|---|---|---|---|
| Raw project brief | `human:director` | **REQUIRED** | Hard blocker — nothing can start |
| Feedback channel to `human:director` | Process capability | **REQUIRED** | Any gap or conflict cannot be resolved; step stalls |
| Project manifest template | Toolkit | **REQUIRED** | No schema to structure the output against; available by default |

### Information Required Within the Brief

These are the information elements the brief must contain, either directly or through clarification. They are not separate inputs — they are the expected content of the brief.

| Information | Requirement | Absent = |
|---|---|---|
| Project name | **REQUIRED** | BLOCKING — no identifier for any downstream artefact |
| Project description | **REQUIRED** | BLOCKING — scope is undefined |
| Approach / technology declaration | **REQUIRED** | BLOCKING — Step 2 cannot begin; no basis for environment specification |
| Deployment target | **REQUIRED** | BLOCKING — Step 2 cannot begin; deployment context missing |
| Development environment | **REQUIRED** | BLOCKING — Step 2 cannot begin; local setup unknown |
| Human actors and roles | **REQUIRED** | BLOCKING — governance is undefined; no approval authority identified |
| Appetite declaration | **REQUIRED** | BLOCKING — scope cannot be bounded; project scale is unknown |
| Known constraints | OPTIONAL | WARNING — downstream work may violate unstated constraints |
| Existing assets | OPTIONAL | LOW RISK — noted as absent; no downstream dependency |
| Reference examples | OPTIONAL | LOW RISK — noted as absent; no downstream dependency |
| Integration requirements | OPTIONAL | WARNING — may surface as gaps in environment specification |
| Explicit out-of-scope declarations | OPTIONAL | WARNING — scope boundary is implied rather than stated |

**Classification rule for absent REQUIRED information:**

Not all missing required information is identical. Before deciding whether to block or proceed:

- If a required field is **absent**: it is `BLOCKING` — the step must obtain it before drafting the manifest
- If a required field is **ambiguous** (present but unclear): classify against this test — *would getting this wrong cause Step 2 or Step 3 to fail?* If yes, it is `BLOCKING`. If no, it is an `OPEN_QUESTION` in the output
- If a required field is **in conflict** with another element of the brief: it is `BLOCKING` — contradictions must be resolved before drafting, never silently resolved by choosing one interpretation

### Detailed Input Specifications

#### Raw project brief

| Criterion | Requirement |
|---|---|
| **Format** | Any — freeform prose, email, conversation transcript, structured document, voice memo transcript, or combination of forms |
| **Source** | Must originate from `human:director`, not an intermediary or synthesised summary |
| **Version** | If multiple versions exist, the most recent version supersedes earlier versions entirely; all versions must be on record |
| **Language** | Must be interpretable without domain expertise the structuring process does not possess — if the brief requires specialist knowledge to interpret, that is a gap to surface, not to fill |
| **Completeness** | The brief does not need to be complete to be valid as an input — gaps become `BLOCKING` items or `OPEN_QUESTIONS` in the output |

#### Feedback channel to `human:director`

| Criterion | Requirement |
|---|---|
| **Availability** | Must be accessible during this step to resolve `BLOCKING` gaps |
| **Format** | Questions must be specific and singular — one question per blocking item, not a consolidated list that the human must parse |
| **Record** | Every question asked and every answer received must be recorded with attribution and timestamp |
| **Scope** | The channel is used only for resolving gaps in the brief — not for design decisions, not for scope negotiation, not for preference-gathering |

#### Project manifest template

| Criterion | Requirement |
|---|---|
| **Format** | Markdown, with explicitly labelled required and optional fields |
| **Currency** | Must be the current version in the toolkit — not a prior version, not a local copy |
| **Authority** | Defines the schema the output must conform to — the output cannot introduce fields not in the schema, and cannot omit required fields |

***

## Outputs

### Summary

| Output | Requirement | If Absent or Incomplete |
|---|---|---|
| `project-manifest.md` in `APPROVED` status | **REQUIRED** | BLOCKER — Step 1 is not done |
| All required fields non-empty or explicitly documented as open questions | **REQUIRED** | BLOCKER — manifest is structurally incomplete |
| `open_questions` entries for every identified gap and ambiguity | **REQUIRED** | WARNING — untracked gaps will surface uncontrolled in later steps |
| Source traceability for all field values | **REQUIRED** | BLOCKER — no way to verify the no-invention constraint was met |
| Approval timestamp attributed to `human:director` | **REQUIRED** | BLOCKER — approval is a claim without evidence |
| Optional fields populated where the brief contained relevant information | EXPECTED | WARNING — information was available but not captured |

### Detailed Output Specifications

#### `project-manifest.md` — schema

Every field listed below must be present in the document. Required fields must be non-empty. Optional fields must be present in the document even if empty — use `none stated` or an empty list `[]`, never omit the field.

| Field | Type | Requirement | Format rule |
|---|---|---|---|
| `project_id` | String | **REQUIRED** | Kebab-case; lowercase; hyphens only; no spaces; no special characters. Derived from `project_name` if not provided explicitly. Example: `petes-plumbing-site` |
| `project_name` | String | **REQUIRED** | Human-readable; use `human:director`'s words exactly — do not normalise, correct capitalisation, or rewrite |
| `description` | String | **REQUIRED** | 2–4 sentences; drawn from the brief without addition; if the brief is vague, write what was said and flag in `open_questions` |
| `tech_stack` | List of strings | **REQUIRED** | Named technologies only — not categories. `AstroJS 5.x` is valid; `modern frontend stack` is not. Minimum one entry. |
| `deployment_target` | String | **REQUIRED** | Named deployment provider and target; minimum provider name; ideally includes URL and staging/production distinction |
| `dev_environment` | Object | **REQUIRED** | Minimum: OS, runtime, package manager. Ideally: editor, start command, any local setup notes |
| `human_actors` | List of objects | **REQUIRED** | Minimum one entry. Each entry: `name`, `role`. Valid roles: `human:director`, `human:approver`, or `other:[description]`. One `human:director` must exist. `human:director` and `human:approver` may be the same person — record both roles on one entry |
| `appetite` | Enum | **REQUIRED** | One of: `small` (days), `medium` (1–2 weeks), `large` (multi-week). If `human:director` stated a specific duration, record it verbatim. Do not infer from apparent scope. |
| `constraints` | List of strings | OPTIONAL | Only constraints explicitly stated by `human:director`; do not infer from the tech stack |
| `out_of_scope` | List of strings | OPTIONAL | Only what `human:director` explicitly excluded; absence of mention ≠ out of scope |
| `open_questions` | List of objects | OPTIONAL — but often non-empty | Each entry: `field` (which manifest field), `gap` (what is missing or unclear), `impact` (what fails downstream), `classification` (`BLOCKING_RESOLVED`, `WARNING`, or `LOW_RISK`) |
| `status` | Enum | **REQUIRED** | Set to `DRAFT` on creation. Set to `APPROVED` only by `human:director` action. Never self-set to `APPROVED`. |
| `created` | ISO 8601 datetime | **REQUIRED** | Set at creation. Never modified after initial write. |
| `approved_at` | ISO 8601 datetime | Conditional | Required when `status = APPROVED`. Set at the moment of approval. |
| `approved_by` | String | Conditional | Required when `status = APPROVED`. Must be the name of the `human:director` actor as declared in `human_actors`. |

#### Source traceability record

This is not a field in the manifest — it is a companion record produced alongside the manifest. It maps every non-empty manifest field value to its source: either a specific element of the original brief (e.g., "stated in email paragraph 2") or a specific clarification answer (e.g., "clarification question Q1, answered [date]").

This record is not delivered to `human:director` for approval — it is retained as the evidence basis for the no-invention constraint check. A manifest field with no traceable source is a violation of that constraint.

***

## Definition of Done

### Summary

Step 1 is done when all nine conditions are simultaneously true:

1. `project-manifest.md` exists at the canonical path
2. `status` field is `APPROVED`
3. All required fields are non-empty
4. Every field value is traceable to a source in the brief or a recorded clarification
5. No value was invented
6. Every gap and ambiguity identified during processing is present in `open_questions` with its classification
7. All contradictions in the brief were resolved and recorded before the manifest was drafted
8. `APPROVED` status was set by `human:director`'s explicit action — not by the process that produced the manifest
9. The approval is timestamped and attributed to the named `human:director` actor

### Unambiguous Requirement Breakdown

#### DoD 1 — `project-manifest.md` exists at the canonical path

- The file exists at `[project-root]/.framework/project-manifest.md`
- The file is not empty
- The file is valid markdown
- **Fails if:** The file is missing, the file is at a different path, the file is present but empty, the path convention has not been established yet (this surfaces a missing bootstrap prerequisite)

#### DoD 2 — `status` field is `APPROVED`

- The `status` field is present in the document
- The field value is exactly `APPROVED` (case-sensitive)
- The `approved_at` field is present and contains a valid ISO 8601 datetime
- The `approved_by` field is present and matches the name of a `human:director` actor in `human_actors`
- **Fails if:** `status` is `DRAFT`, the field is missing, `approved_at` is absent, `approved_by` is absent, or `approved_by` does not match any `human:director` entry

#### DoD 3 — All required fields are non-empty

- Every field in the schema marked REQUIRED contains a value
- `tech_stack` contains at least one entry
- `human_actors` contains at least one entry with role `human:director`
- `appetite` is one of the three valid enum values
- **Fails if:** Any required field is missing from the document, any required field is empty or null, `tech_stack` is an empty list, `human_actors` has no `human:director` entry, or `appetite` contains a value not in the valid enum

#### DoD 4 — Every field value is traceable to a source

- The source traceability record exists
- Every non-empty field in the manifest has a corresponding entry in the traceability record
- Each traceability entry identifies either: a specific element of the original brief (with enough specificity to locate it), or a specific recorded clarification (identified by question ID and date)
- **Fails if:** The traceability record is absent, any field has no corresponding traceability entry, any traceability entry is vague ("from the brief" without specificity is not sufficient)

#### DoD 5 — No value was invented

- No field contains information that cannot be found in the original brief or a recorded clarification answer
- Inferences from one field to another are permitted only where the inference is unambiguous and documented in `open_questions` (e.g., deriving `project_id` from `project_name` is a documented derivation, not an invention)
- Optional field values that were absent in the brief must be recorded as empty — not populated with reasonable assumptions
- **Fails if:** Any field contains information with no traceable source, any optional field is populated with inferred or assumed content without a corresponding `open_questions` entry documenting the assumption

#### DoD 6 — Every gap and ambiguity is in `open_questions`

- Every required field that was absent in the original brief and resolved through clarification has a `BLOCKING_RESOLVED` entry in `open_questions`
- Every optional field that was absent in the brief has a `WARNING` or `LOW_RISK` entry in `open_questions`
- Every field that was ambiguous in the brief (present but unclear) has an entry recording the ambiguity and how it was resolved, or confirming it remained unresolved
- **Fails if:** `open_questions` is empty on a manifest where the brief was known to be incomplete, or if an ambiguity that was identified during processing has no corresponding entry

#### DoD 7 — Contradictions were resolved before drafting

- No manifest field contains a value that contradicts another manifest field
- Any contradiction that existed in the original brief is referenced in `open_questions` with a note on how it was resolved
- The resolution was recorded at the time of clarification — not applied silently
- **Fails if:** Two manifest fields contradict each other, a contradiction was identified in the brief but the manifest reflects one side without documentation of the resolution

#### DoD 8 — `APPROVED` status was set by `human:director`'s explicit action

- The approval was not automatic or triggered by a process condition
- The human took a deliberate action (confirmed in the record) that caused the status transition
- The record of the approval action exists independently of the manifest field — the field value alone is not sufficient evidence
- **Fails if:** There is no record of an approval action by `human:director`, the status was set programmatically based on completeness rather than explicit human confirmation, or the approval record attributes the action to any party other than `human:director`

#### DoD 9 — Approval is timestamped and attributed

- `approved_at` contains the exact datetime of the approval action in ISO 8601 format with timezone
- `approved_by` contains the name of the `human:director` actor exactly as recorded in `human_actors`
- **Fails if:** Either field is absent, either field contains a placeholder value, the datetime is not in ISO 8601 format, or `approved_by` does not match the `human_actors` record

***

## Tasks

These are the discrete units of work that take the inputs and produce the output. They are in dependency order. No task begins until the preceding task is complete.

***

### Task 1.1 — Brief Inventory

**Question:** What is in the brief, and does it map to the required schema?

**Input:** Raw project brief (in whatever form received)

**Output:** A classified inventory — every element of the brief mapped to a manifest field, or noted as non-mappable; every required field classified as `PRESENT`, `ABSENT`, or `AMBIGUOUS`

**Subtasks:**
- Read the brief in full before beginning any classification
- For each required field in the manifest schema: identify whether the brief contains sufficient information to populate it
- For each optional field: identify whether the brief contains relevant information
- Note any information in the brief that does not map to any field — this may indicate scope, constraints, or out-of-scope material not yet captured
- Note any apparent contradictions between elements of the brief

**Done when:**
- Every required field is classified
- Every optional field has a `PRESENT` or `ABSENT` classification
- Apparent contradictions are noted
- Non-mappable information is noted for consideration

***

### Task 1.2 — Gap Classification

**Question:** Which gaps are blocking and which can be surfaced as open questions?

**Input:** Classified inventory from Task 1.1

**Output:** A two-tier gap list: `BLOCKING` items (must be resolved before drafting) and `OPEN_QUESTIONS` (will be documented in the manifest but do not block drafting)

**Subtasks:**
- For each `ABSENT` or `AMBIGUOUS` required field: apply the classification test — *would getting this wrong, or proceeding without it, cause Step 2 or Step 3 to fail?* If yes: `BLOCKING`. If no: `OPEN_QUESTION`
- For each `ABSENT` optional field: classify as `WARNING` (has downstream impact on quality) or `LOW_RISK` (no downstream dependency)
- For each contradiction noted in Task 1.1: classify as `BLOCKING` — contradictions are never downgraded

**Done when:**
- Every gap has a classification
- Every contradiction has been identified as a `BLOCKING` item
- The gap list distinguishes items that prevent drafting from items that can be documented and surfaced at the human review gate

***

### Task 1.3 — Clarification Resolution *(conditional — only if `BLOCKING` items exist)*

**Question:** Can each blocking gap be resolved by asking `human:director` directly?

**Input:** `BLOCKING` gap list from Task 1.2; feedback channel to `human:director`

**Output:** Resolved values for all `BLOCKING` gaps, or confirmation that a gap is genuinely unknown (which becomes a documented `OPEN_QUESTION` rather than a blocking gap)

**Subtasks:**
- For each `BLOCKING` item: formulate a specific, answerable question — one question per item, not a consolidated list
- Record the question with: the field it relates to, why it is blocking, and the date/time asked
- Receive and record the answer with: the answer content, the date/time received, and attribution to `human:director`
- Reclassify the item: either `BLOCKING_RESOLVED` (answer received), or `BLOCKING_CONFIRMED_UNKNOWN` (human:director confirmed they cannot answer — downgrade to `OPEN_QUESTION`)
- Repeat until all `BLOCKING` items are resolved or confirmed unknown

**This task may loop.** Each loop is a single question-and-answer exchange. There is no maximum number of loops. The exit condition is: no remaining `BLOCKING` items that have neither a resolved value nor a `CONFIRMED_UNKNOWN` status.

**Done when:**
- No `BLOCKING` items remain without a status of `RESOLVED` or `CONFIRMED_UNKNOWN`
- Every question asked and every answer received is recorded with timestamp and attribution
- Contradictions resolved through this task have a documented resolution rationale

***

### Task 1.4 — Manifest Drafting

**Question:** Can all confirmed values be structured into a valid, traceable manifest?

**Input:** Classified inventory (1.1), gap classification (1.2), resolved clarifications (1.3 if run), project manifest template

**Output:** `project-manifest.md` in `DRAFT` status

**Subtasks:**
- Open the manifest template and begin populating fields
- For each required field: populate with the confirmed value, or write the `OPEN_QUESTION` entry if the gap was confirmed unknown
- For each optional field: populate with the confirmed value, or record as `none stated` / `[]`
- For each `open_questions` entry: include `field`, `gap`, `impact`, and `classification`
- Build the source traceability record alongside the manifest — every field value is entered with its source before moving to the next field
- Set `status` to `DRAFT`
- Set `created` to the current datetime in ISO 8601 format
- Do not set `approved_at` or `approved_by` — these are set only at Task 1.5

**Self-check before completing this task:**
- All required fields are non-empty
- No value was entered without a corresponding traceability entry
- `tech_stack` has at least one named technology
- `human_actors` has at least one `human:director` entry
- `appetite` is one of the three valid values
- `status` is `DRAFT`
- Every contradiction resolution is documented in `open_questions`

**Done when:** The manifest is complete against the schema, `status = DRAFT`, and the source traceability record covers every non-empty field

***

### Task 1.5 — Human Review

**Question:** Does `human:director` confirm that the manifest accurately represents their intent?

**Input:** `DRAFT` project-manifest.md from Task 1.4

**Output:** `APPROVED` project-manifest.md, or `RETURNED` manifest with specific corrections

**Subtasks:**
- Present the draft manifest to `human:director` for review
- `human:director` reads the manifest and either:
  - **Approves:** confirms the manifest accurately represents their intent; no corrections required
  - **Returns with corrections:** identifies specific fields that are wrong, missing, or misrepresent their intent; each correction is specific and actionable
- If `RETURNED`:
  - Apply each correction to the manifest
  - Update the source traceability record for any changed fields
  - Verify no new gaps were introduced by the corrections
  - Return to the beginning of Task 1.5 with the corrected draft
- If `APPROVED`:
  - Record the approval action with timestamp
  - Set `status` to `APPROVED`
  - Set `approved_at` to the datetime of the approval action (ISO 8601 with timezone)
  - Set `approved_by` to the name of the `human:director` actor as recorded in `human_actors`

**This task may loop.** Each revision cycle is one `RETURNED` → correction → re-review loop. There is no maximum number of cycles. The exit condition is explicit `APPROVED` status.

**Done when:** `status = APPROVED`, `approved_at` is set, `approved_by` is set and matches the `human:director` entry in `human_actors`, and the approval action is on record

***

## Items to Flag for Higher-Level Consideration

These elements emerged from detailing Step 1 but do not belong within Step 1's policy. They are cross-cutting concerns that likely appear in multiple steps.

**F1 — The No-Invention Invariant**
The constraint that no output field value may be invented — everything must trace to a source — is not unique to Step 1. It applies wherever structured output is produced from human-provided or structured input. This belongs as a framework-level constraint referenced by step policies, not defined within them.

**F2 — The Gap Classification Taxonomy**
The `BLOCKING` / `OPEN_QUESTION` / `WARNING` / `LOW_RISK` classification system is reusable. Step 2 will need to classify gaps in the tech stack declaration against environment contract fields. The same taxonomy applies. Define it once at framework level.

**F3 — The Clarification Protocol**
The rules for how to request clarification from a human — one question per item, record question and answer with timestamps, attribution — are not Step 1-specific. Any step that encounters a blocking gap and has a human feedback channel will need the same protocol. Define once.

**F4 — The Human Approval Record Pattern**
The requirement that a human approval is recorded with timestamp, attribution, and an action reference (not just a field value) appears in Step 1 and will appear in Step 5. The mechanism for recording human decisions — the what, when, and who — belongs at framework level.

**F5 — The Source Traceability Record**
The companion record that maps every output field to its input source is a pattern that will likely appear wherever structured transformation occurs (brief → manifest, manifest → environment contract). The format and retention rules should be defined at framework level so every step applies them consistently.
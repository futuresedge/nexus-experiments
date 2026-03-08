# Step 1 Policy: Project Intent Capture
**Version:** 0.2 — Draft
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
| Project name | **REQUIRED** | BLOCKER — no identifier for any downstream artefact |
| Project description | **REQUIRED** | BLOCKER — scope is undefined |
| Approach / technology declaration | **REQUIRED** | BLOCKER — Step 2 cannot begin; no basis for environment specification |
| Deployment target | **REQUIRED** | BLOCKER — Step 2 cannot begin; deployment context missing |
| Development environment | **REQUIRED** | BLOCKER — Step 2 cannot begin; local setup unknown |
| Human actors and roles | **REQUIRED** | BLOCKER — governance is undefined; no approval authority identified |
| Appetite declaration | **REQUIRED** | BLOCKER — scope cannot be bounded; project scale is unknown |
| Known constraints | OPTIONAL | WARNING — downstream work may violate unstated constraints |
| Existing assets | OPTIONAL | INFO — noted as absent; no downstream dependency |
| Reference examples | OPTIONAL | INFO — noted as absent; no downstream dependency |
| Integration requirements | OPTIONAL | WARNING — may surface as gaps in environment specification |
| Explicit out-of-scope declarations | OPTIONAL | WARNING — scope boundary is implied rather than stated |

**Classification rule for absent REQUIRED information:**

Not all missing required information is identical. Before deciding whether to block or proceed:

- If a required field is **absent**: it is `BLOCKER` — the step must obtain it before drafting the manifest
- If a required field is **ambiguous** (present but unclear): classify against this test — *would getting this wrong cause Step 2 or Step 3 to fail?* If yes, it is `BLOCKER`. If no, it is an open question in the output
- If a required field is **in conflict** with another element of the brief: it is `BLOCKER` — contradictions must be resolved before drafting, never silently resolved by choosing one interpretation

### Detailed Input Specifications

#### Raw project brief

| Criterion | Requirement |
|---|---|
| **Format** | Any — freeform prose, email, conversation transcript, structured document, voice memo transcript, or combination of forms |
| **Source** | Must originate from `human:director`, not an intermediary or synthesised summary |
| **Version** | If multiple versions exist, the most recent version supersedes earlier versions entirely; all versions must be on record |
| **Language** | Must be interpretable without domain expertise the structuring process does not possess — if the brief requires specialist knowledge to interpret, that is a gap to surface, not to fill |
| **Completeness** | The brief does not need to be complete to be valid as an input — gaps become `BLOCKER` items or open questions in the output |

#### Feedback channel to `human:director`

| Criterion | Requirement |
|---|---|
| **Availability** | Must be accessible during this step to resolve `BLOCKER` gaps |
| **Format** | One question per gap — each gap produces exactly one question — all questions delivered in a single batch exchange (see FC-3). Questions must be specific and singular, not compound. |
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
| `project-manifest.yaml` in `APPROVED` status | **REQUIRED** | BLOCKER — Step 1 is not done |
| `open-questions-register.yaml` created and populated | **REQUIRED** | BLOCKER — gap tracking has no canonical home; carry-forward to Step 2 is broken |
| All required fields non-empty or explicitly documented as open questions | **REQUIRED** | BLOCKER — manifest is structurally incomplete |
| `open_questions` entries for every identified gap and ambiguity | **REQUIRED** | WARNING — untracked gaps will surface uncontrolled in later steps |
| Source traceability for all field values | **REQUIRED** | BLOCKER — no way to verify the no-invention constraint was met |
| Approval timestamp attributed to `human:director` | **REQUIRED** | BLOCKER — approval is a claim without evidence |
| `approval_statement` verbatim from `human:director` | **REQUIRED** | BLOCKER — FC-4 Tier 1 requires deliberate evidence of approval, not just a status field |
| Optional fields populated where the brief contained relevant information | EXPECTED | WARNING — information was available but not captured |

### Detailed Output Specifications

#### `project-manifest.yaml` — schema

Every field listed below must be present in the document. Required fields must be non-empty. Optional fields must be present in the document even if empty — use `none stated` or an empty list `[]`, never omit the field.

| Field | Type | Requirement | Format rule |
|---|---|---|---|
| `project_id` | String | **REQUIRED** | Kebab-case; lowercase; hyphens only; no spaces; no special characters. Derived from `project_name` if not provided explicitly. Example: `petes-plumbing-site` |
| `project_name` | String | **REQUIRED** | Human-readable; use `human:director`'s words exactly — do not normalise, correct capitalisation, or rewrite |
| `description` | String | **REQUIRED** | 2–4 sentences; drawn from the brief without addition; if the brief is vague, write what was said and flag in `open_questions` |
| `tech_stack` | List of strings | **REQUIRED** | Named technologies only — not categories. `AstroJS 5.x` is valid; `modern frontend stack` is not. Minimum one entry. |
| `deployment_target` | String | **REQUIRED** | Named deployment provider and target; minimum provider name; ideally includes URL and staging/production distinction |
| `dev_environment` | Object | **REQUIRED** | Minimum: OS, runtime, package manager. Note: package managers (e.g. `pnpm`) may appear in both `tech_stack` and `dev_environment.package_manager` — duplication is intentional and permitted. Ideally: editor, start command, any local setup notes |
| `human_actors` | List of objects | **REQUIRED** | Minimum one entry. Each entry: `name`, `role`. Valid roles: `human:director`, `human:approver`, or `other:[description]`. One `human:director` must exist. `human:director` and `human:approver` may be the same person — record both roles on one entry |
| `appetite` | Enum | **REQUIRED** | One of: `small` (days), `medium` (1–2 weeks), `large` (multi-week). If `human:director` stated a specific duration, record it verbatim in `open_questions` alongside the enum value. Do not infer from apparent scope — absent or invalid appetite is a Gate 3 BLOCKER regardless of downstream step dependency. |
| `existing_infrastructure` | Object | OPTIONAL | Any pre-existing setup relevant to deployment or hosting: registered domains, existing hosting accounts, DNS control. No current field = `schema_gap_flag: true` in the register. |
| `success_criteria` | List of strings | OPTIONAL | `human:director`'s explicit definition of done for the project. If absent, note in `open_questions`. |
| `constraints` | List of strings | OPTIONAL | Only constraints explicitly stated by `human:director`; do not infer from the tech stack |
| `out_of_scope` | List of strings | OPTIONAL | Only what `human:director` explicitly excluded; absence of mention ≠ out of scope |
| `integration_requirements` | Object | OPTIONAL | External services or integrations referenced in the brief. If mentioned but unconfirmed, record what was said, note it is tentative, and cross-reference the open question ID. Do not record a tentative value as confirmed. |
| `reference_examples` | List of strings | OPTIONAL | Named examples cited by `human:director`. Named examples with qualitative descriptors (e.g. "like Airbnb but simpler") captured as-stated; descriptors that cannot be mapped to a field go to `non_mappable`. |
| `open_questions` | List of objects | OPTIONAL — but often non-empty | Full schema per entry: `question_id`, `field`, `gap`, `gap_type` (`ABSENT`\|`AMBIGUOUS-INCOMPLETE`\|`AMBIGUOUS-FORMAT`\|`CONTRADICTION`\|`SCHEMA-GAP`), `impact`, `classification` (`BLOCKER:RESOLVED`\|`WARNING`\|`INFO`\|`BLOCKER:CONFIRMED-UNKNOWN`), `flags` (optional — `POTENTIAL-CONTRADICTION`), `linked_questions` (array — `[]` if none), `schema_gap_flag` (optional bool), `decision_request_ref` (optional `DR-xx` ID), `resolution_status` (`UNRESOLVED`\|`RESOLVED`\|`CONFIRMED-UNKNOWN`\|`AWAITING-DECISION`) |
| `status` | Enum | **REQUIRED** | Set to `DRAFT` on creation, only after the self-check passes. Set to `APPROVED` only by `human:director` action. Never self-set to `APPROVED`. |
| `created` | ISO 8601 datetime | **REQUIRED** | Set at creation. Never modified after initial write. |
| `approved_at` | ISO 8601 datetime | Conditional | Required when `status = APPROVED`. Set to the datetime of the **human approval action** — not the executor's processing timestamp. In asynchronous workflows these are distinct events; the human action timestamp is authoritative. |
| `approved_by` | String | Conditional | Required when `status = APPROVED`. Must be the name of the `human:director` actor as declared in `human_actors`. |
| `approval_statement` | String | Conditional | Required when `status = APPROVED`. Verbatim words from `human:director`'s approval response, minimum 5 words. Must be authored by the human — not a template phrase generated by the executor. |

#### Source traceability record

This is not a field in the manifest — it is a companion record produced alongside the manifest. It maps every non-empty manifest field value to its source: either a specific element of the original brief (e.g., "stated in email paragraph 2") or a specific clarification answer (e.g., "clarification question Q1, answered [date]").

This record is not delivered to `human:director` for approval — it is retained as the evidence basis for the no-invention constraint check. A manifest field with no traceable source is a violation of that constraint.

***

## Definition of Done

### Summary

Step 1 is done when all ten conditions are simultaneously true:

1. `project-manifest.yaml` exists at the canonical path
2. `status` field is `APPROVED`
3. All required fields are non-empty
4. Every field value is traceable to a source in the brief or a recorded clarification
5. No value was invented
6. Every gap and ambiguity identified during processing is present in `open-questions-register.yaml` with its classification
7. All contradictions in the brief were resolved and recorded before the manifest was drafted
8. `APPROVED` status was set by `human:director`'s explicit action — not by the process that produced the manifest
9. The approval is timestamped and attributed to the named `human:director` actor
10. An `approval_statement` containing `human:director`'s verbatim words is recorded in the manifest

### Unambiguous Requirement Breakdown

#### DoD 1 — `project-manifest.yaml` exists at the canonical path

- The file exists at `[project-root]/.framework/project-manifest.yaml`
- The file is not empty
- The file is valid YAML
- The companion `project-manifest.traceability.yaml` exists at `[project-root]/.framework/traceability/project-manifest.traceability.yaml`
- **Fails if:** Either file is missing, either file is at a different path, either file is present but empty, or the path convention has not been established yet

#### DoD 2 — `status` field is `APPROVED`

- The `status` field is present in the document
- The field value is exactly `APPROVED` (case-sensitive)
- The `approved_at` field is present and contains a valid ISO 8601 datetime with timezone — set to the **human approval action** timestamp, not the executor's processing timestamp
- The `approved_by` field is present and matches the name of a `human:director` actor in `human_actors`
- The `approval_statement` field is present and contains verbatim words from `human:director`'s approval response, minimum 5 words
- **Fails if:** `status` is `DRAFT`, the field is missing, `approved_at` is absent or contains an executor timestamp, `approved_by` is absent or does not match any `human:director` entry, or `approval_statement` is absent or contains fewer than 5 words

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

#### DoD 6 — Every gap and ambiguity is in `open-questions-register.yaml`

- Every required field that was absent in the original brief and resolved through clarification has a `BLOCKER:RESOLVED` entry in the register
- Every optional field that was absent in the brief has a `WARNING` or `INFO` entry in the register
- Every field that was ambiguous in the brief (present but unclear) has an entry recording the ambiguity and how it was resolved, or confirming it remained unresolved
- Every `non_mappable[]` entry from `brief-inventory.yaml` has either a register entry or a documented no-entry decision
- **Fails if:** The register is empty on a manifest where the brief was known to be incomplete, or if an ambiguity that was identified during processing has no corresponding entry, or if any `non_mappable[]` entry was silently skipped

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

- `approved_at` contains the exact datetime of the **human approval action** in ISO 8601 format with timezone
- `approved_by` contains the name of the `human:director` actor exactly as recorded in `human_actors`
- **Fails if:** Either field is absent, either field contains a placeholder value, the datetime is not in ISO 8601 format, `approved_by` does not match the `human_actors` record, or `approved_at` was set to the executor's processing timestamp rather than the human's action timestamp

#### DoD 10 — `approval_statement` is present and verbatim

- `approval_statement` is present in the manifest
- The value contains the verbatim words of `human:director`'s approval response
- Minimum 5 words
- The value was not generated by the executor — it is a direct quotation of what `human:director` wrote or said
- **Fails if:** The field is absent, the value is fewer than 5 words, or the value is a template phrase authored by the executor rather than a quotation from `human:director`

***

## Tasks

These are the discrete units of work that take the inputs and produce the output. They are in dependency order. No task begins until the preceding task is complete.

***

### Task 1.1 — Brief Inventory

**Question:** What is in the brief, and how does it map to the required schema?

**Input:** Raw project brief (in whatever form received)

**Output:** `brief-inventory.yaml` — a single structured YAML document with four arrays:
- `statements[]` — every meaningful statement in the brief, each tagged with a schema field mapping or `NON_MAPPABLE`
- `fields[]` — one entry per manifest field, with a presence classification and `gap_type` where applicable
- `non_mappable[]` — statements that do not map to any manifest field
- `contradictions[]` — pairs of statements that are in apparent conflict

**Standing precondition for all subtasks:** Read the brief in full before beginning any subtask. Do not begin classification before the full brief has been read.

**Subtask 1 — Statement inventory:**
For each meaningful statement in the brief, create an entry in `statements[]` with:
- `text`: the statement verbatim or faithfully paraphrased
- `maps_to`: the manifest field name it maps to, or `NON_MAPPABLE` if no field applies

**Subtask 2 — Field classification:**
For each manifest schema field, create an entry in `fields[]` with:
- `field`: the field name
- `presence`: one of `PRESENT` / `ABSENT` / `AMBIGUOUS`
- `gap_type` (required when `presence ≠ PRESENT`):
  - `ABSENT` — no information provided
  - `AMBIGUOUS-INCOMPLETE` — partial information present (some but not all needed)
  - `AMBIGUOUS-FORMAT` — information present but not in a valid field format

This `gap_type` classification propagates directly to Task 1.3 question formulation — it determines the type of question asked. Do not skip it.

**Subtask 3 — Contradiction detection:**
Scan across all sections of the brief. Contradictions can span required and optional sections, and can exist between a field value and known domain knowledge — do not limit scanning to required fields only.

For each apparent conflict, create an entry in `contradictions[]` with:
- `statements`: the two conflicting items (by reference or verbatim)
- `classification`:
  - `CONTRADICTION` — the conflict is determinable without domain expertise
  - `POTENTIAL-CONTRADICTION` — resolving it requires domain expertise the executor does not hold; add `contradiction_flag: true`

**Subtask 4 — Non-mappable classification:**
For each statement tagged `NON_MAPPABLE` in `statements[]`, create an entry in `non_mappable[]` with:
- `text`: the statement
- `reason`: why it does not map to any current schema field
- `downstream_consequence`: whether it has implications for Step 2, Step 3, or later (yes/no with a brief note)

**Done when:**
- Every required and optional schema field has a `fields[]` entry with `presence` classification
- Every statement in the brief has a `statements[]` entry
- `contradictions[]` is complete — including inter-section and domain-knowledge-dependent conflicts
- `non_mappable[]` contains every statement tagged `NON_MAPPABLE`
- `brief-inventory.yaml` is written and filed

***

### Task 1.2 — Gap Classification

**Question:** Which gaps are blocking and which can be surfaced as open questions?

**Required inputs before beginning:**
- `brief-inventory.yaml` from Task 1.1
- Step 2 policy document (loaded as reference material — Gate 1 cannot be applied without knowledge of what each downstream step needs per field)
- Step 3 policy document (same reason)
- Manifest template conditional sections table (maps tech stack patterns to triggered optional sections)

**Output:** `open-questions-register.yaml` — this is Task 1.2's primary output. It is not a separate intermediate document. Every gap identified across all subtasks produces a register entry.

**Gap severity vocabulary:**
- `BLOCKER` — must be resolved before the manifest can be drafted
- `WARNING` — step may proceed; downstream impact is known and specific
- `INFO` — step may proceed; downstream impact is negligible

**Terminal states for BLOCKER entries:**
- `BLOCKER:RESOLVED` — resolved through the clarification protocol (Task 1.3)
- `BLOCKER:CONFIRMED-UNKNOWN` — `human:director` confirmed they cannot provide this; downgraded to open question

**Gates (applied per field):**
- **Gate 1:** *"Would proceeding without this, or getting it wrong, cause Step 2 or Step 3 to fail?"* YES → `BLOCKER`; NO → apply Gate 2
- **Gate 2:** *"Does the absence of this field have a known, specific downstream quality impact?"* YES → `WARNING`; NO → `INFO`
- **Gate 3 (independent, applied when a value is present):** *"Does the value supplied satisfy the field's type, domain, and constraint requirements?"* NO → `BLOCKER`, regardless of Gate 1/2 results. A required field with an invalid value fails Gate 3 even though Gate 1 returns NO (a value was present). The `appetite` case is canonical: a value was present but violated domain constraints — Gates 1 and 2 both miss this without Gate 3.

**Subtask 1 — Required field gaps:**
For each `fields[]` entry with `presence ≠ PRESENT` and REQUIRED constraint:
- Apply Gates 1, 2, and 3 in sequence
- Create a register entry with: `question_id`, `field`, `gap`, `gap_type` (from the `fields[]` entry), `impact`, `classification`, `linked_questions: []`, `resolution_status: UNRESOLVED`

**Subtask 2 — Optional field gaps:**
For each optional field in `fields[]`:
- Apply classification gates (1, 2, and Gate 3 if a value is present but suspect)
- Consult the conditional sections table: if the tech stack pattern makes an optional field contextually required, promote to `BLOCKER` if absent
- Every optional field must be explicitly assessed — fields classified as having no downstream impact still require a documented assessment. Silent skipping is not acceptable.
- **Done condition:** The executor must be able to affirm explicitly that every optional field was assessed and either received a register entry or a documented no-entry decision.

**Subtask 3 — Contradiction classification:**
For each entry in `contradictions[]`:
- `CONTRADICTION`: classify as `BLOCKER`
- `POTENTIAL-CONTRADICTION`: classify as `WARNING` with `flags: POTENTIAL-CONTRADICTION` and `contradiction_flag: true`. The step does not attempt to resolve the contradiction autonomously. If the contradiction is confirmed during Task 1.3, the entry is immediately reclassified `BLOCKER` and FC-3 is re-invoked.

**Linking pass (explicit named step — run after Subtask 3, before Subtask 4):**
For each register entry, set `linked_questions` bidirectionally: for every entry A that references entry B's `question_id` in its `linked_questions`, confirm that entry B also references entry A. Task 1.3 queries this field to detect consolidation opportunities and propagate resolutions — bidirectionality must be correct before Task 1.3 begins.

**Subtask 4 — Non-mappable statement classification:**
For each entry in `non_mappable[]` from `brief-inventory.yaml`:
- Assess: does this statement have downstream consequences (Step 2, Step 3, or later)?
- If yes: create a register entry. If no manifest schema field exists to hold this information, set `gap_type: SCHEMA-GAP`, `schema_gap_flag: true`, and optionally `candidate_field` naming the proposed new field
- If no downstream consequences: record a documented no-entry decision for that statement
- **Done condition:** The executor must be able to affirm explicitly that every `non_mappable[]` entry was assessed — no silent skipping.

**Done when:**
- `open-questions-register.yaml` exists and contains entries for every gap from Subtasks 1–4
- Every register entry has a complete schema including `gap_type`, `linked_questions`, and `classification`
- Every optional field and every `non_mappable[]` entry has been explicitly assessed (with register entry or documented decision)
- The bidirectional linking pass is complete
- No register entry is missing because it was silently skipped

***

### Task 1.3 — Clarification Resolution *(conditional — only if `BLOCKER` items exist)*

**Question:** Can each blocking gap be resolved by asking `human:director` directly?

**Input:** `open-questions-register.yaml` from Task 1.2; feedback channel to `human:director`

**Output:** Resolved values for all `BLOCKER` gaps, or confirmation that a gap is genuinely unknown (downgraded to open question), or a Decision Request record (`DR-xx`) for undecided choices

**Subtask 1 — Question formulation and exchange delivery:**

Apply `gap_type` → question type mapping to determine the question form:
- `ABSENT` → value-retrieval: *"What is your X?"*
- `AMBIGUOUS-INCOMPLETE` → value-completeness: *"You've mentioned X — can you confirm [specific missing element]?"*
- `AMBIGUOUS-FORMAT` → choice-based, presenting valid options: *"You said X — which of these valid values best matches: [options]?"*
- `CONTRADICTION` → disambiguation naming both values: *"Your brief contains two statements that appear to conflict: [A] and [B]. Which is correct?"*

Each question must be:
- One sentence, maximum 25 words, addressing a single gap — not compound
- Named by field: *"Which version of Node.js are you running?"* not *"What's the runtime?"*
- Optionally accompanied by a parenthetical retrieval instruction (e.g., "run `node --version` to check") — permitted provided it does not constitute a compound question or a decision prompt
- Accompanied by a one-sentence impact statement

One question per gap. All questions delivered in a **single batch exchange** — not sequentially, not one at a time.

Create the exchange record shell (`CE-1-[seq].yaml`) and file it **before delivery**. Set `initiated_at` at the moment of sending — record creation and delivery are the same moment. Any gap between them is an audit integrity issue.

Group questions by domain for presentation (identity, technical, governance, scope). Present with the instruction: *"Please respond per-question, referencing the question number (e.g., Q1: ..., Q2: ...)."*

**Subtask 2 — Receive and pre-process response:**

Receive `human:director`'s response. If the response does not reference question numbers, map each response element to a question before proceeding. Mapping must be complete before any register entry is updated.

**Subtask 3 — Response classification and register update:**

**Classify before act.** For each response, classify first — before updating any register entry:

| Classification | Condition | Action |
|---|---|---|
| `RESOLVED` | A specific, usable value is provided | Write `resolved_value` in the exchange record; update register entry to `BLOCKER:RESOLVED` |
| `CONFIRMED-UNKNOWN` | `human:director` confirmed they cannot provide this | Update register to `BLOCKER:CONFIRMED-UNKNOWN`; downgrade to `WARNING` open question |
| `DECISION-REQUIRED` | The underlying decision has not been made | FC-9 Human Decision Support Protocol is invoked immediately. Entry remains `BLOCKER`; step enters `AWAITING-DECISION` for this entry. |
| `UNCLEAR` | Response is present but does not clearly map to one of the above | Identify the single follow-up question that resolves the ambiguity; re-present to `human:director`. `initiated_at` of the original exchange does not change; add `follow_up_requested_at` timestamp to the exchange record. |

**Derivation-flagged responses:** *"Latest stable"* and equivalent deferred version references are valid `RESOLVED` responses but are not final manifest values. When this occurs:
- Set `derivation_flag: true` on the exchange record entry
- Note in `resolution_note` that version resolution is required before field population
- Task 1.4 will treat these as pre-drafting derivation items — they must not be written directly to the manifest as-stated

**Linked entry propagation (explicit named step — after classifying each response):**
For each `RESOLVED` entry, query the register for all entries with this entry's `question_id` in their `linked_questions` field. Apply the same resolution to those entries, citing the same exchange reference. A resolved contradiction that leaves its linked ambiguity entry in OPEN status is a register integrity failure.

**This task may loop.** Each loop is a single question-and-answer exchange for the unresolved BLOCKER items. Exit condition: no `BLOCKER` entries remain with status other than `BLOCKER:RESOLVED`, `BLOCKER:CONFIRMED-UNKNOWN`, or `AWAITING-DECISION`.

**Done when:**
- No `BLOCKER` entries remain in UNRESOLVED status
- Every question asked and every answer received is recorded in the exchange record (`CE-1-xx`) with timestamp and attribution
- All `derivation_flag: true` entries are present and flagged for pre-drafting resolution in Task 1.4
- Linked entry propagation has been applied for every `RESOLVED` entry
- `BLOCKER:CONFIRMED-UNKNOWN` entries have been downgraded to open questions in the register

***

### Task 1.4 — Manifest Drafting

**Question:** Can all confirmed values be structured into a valid, traceable manifest?

**Input:** `brief-inventory.yaml` (1.1), `open-questions-register.yaml` (1.2), exchange records from Task 1.3 (if run), project manifest template

**Output:** `project-manifest.yaml` in `DRAFT` status, with companion `project-manifest.traceability.yaml`

**Subtask 1 — Pre-drafting derivation resolution:**

Before any manifest field is written, query all exchange records for entries with `derivation_flag: true`. For each:
- Resolve to a specific, pinnable value (e.g., *"latest stable Node.js"* → `22.x`)
- Record in `project-manifest.traceability.yaml` with `source_type: derivation_rule` and the derivation rule name
- If the lookup is unavailable (no external access, no determinable value): the value becomes `BLOCKER:CONFIRMED-UNKNOWN`; update the register entry accordingly; the manifest field will be written as empty with an `open_questions` entry. Guessing a version number is not a fallback.

If any required field has no valid source after derivation resolution, create a new register entry before beginning Subtask 2. Task 1.4 is a quality gate — it must catch any Task 1.2 omissions before drafting begins.

**Subtask 2 — Field population:**

Populate the manifest field by field. Build `project-manifest.traceability.yaml` alongside — every field value is entered with its source **before** moving to the next field. Do not reconstruct traceability after drafting; post-drafting reconstruction cannot be independently verified.

For each **required field**: populate with the confirmed value, or write the `open_questions` entry if the gap was confirmed unknown.

For each **optional field**:
- If a confirmed value exists: populate
- If `AMBIGUOUS` (partial or tentative information from the brief): record what was said verbatim, note it is tentative, and cross-reference the open question ID. Do not record a tentative value as confirmed. Do not leave the field empty without explanation.
- If absent: record as `none stated` / `[]`

For the **`description` field**: include project type, primary purpose, and key deliverable. Exclude constraints, deployment details, and named actors — these have dedicated fields. Every sentence must trace to a specific brief statement. The executor's voice does not appear — do not rephrase for perceived clarity in ways that could alter meaning.

For **`tech_stack` and `dev_environment.package_manager`**: the same package manager (e.g., `pnpm`) may appear in both. This duplication is intentional and permitted — do not remove a value from one field to avoid duplication.

If a **version-less tech stack entry** is discovered mid-drafting (not caught in Subtask 1): pause field population, create a register entry, resolve via derivation, then write. Pre-drafting may not catch every derivation-dependent field.

**Subtask 3 — Self-check:**

Run the self-check **before** setting `status: DRAFT`. Status `DRAFT` is the executor's assertion of completeness — setting it before the check inverts the purpose.

Self-check items:
- All required fields are non-empty
- No value was entered without a corresponding traceability entry
- `tech_stack` has at least one named technology
- `human_actors` has at least one `human:director` entry
- `appetite` is one of the three valid enum values (`small` / `medium` / `large`)
- Every `AMBIGUOUS` optional field has a tentative-value note and a register cross-reference
- Every contradiction resolution is documented in `open_questions`
- `project-manifest.traceability.yaml` covers every non-empty field

Set `status: DRAFT` and `created: [ISO 8601 datetime]` only after all self-check items pass.

**Done when:** `project-manifest.yaml` is complete against the schema, `status = DRAFT`, and `project-manifest.traceability.yaml` was produced field-by-field during drafting and covers every non-empty field

***

### Task 1.5 — Human Review

**Question:** Does `human:director` confirm that the manifest accurately represents their intent?

**Input:** `project-manifest.yaml` in `DRAFT` status from Task 1.4; `project-manifest.traceability.yaml`

**Output:** `project-manifest.yaml` in `APPROVED` status

**Subtask 1 — Prepare and deliver the review package:**

Generate a summary from the manifest using a deterministic rendering rule (one summary value per manifest field — no synthesis or editorial interpretation). Before delivery, validate every summary value against its corresponding manifest field. A rendering error means `human:director` approves a summary that does not match the canonical document — validation is a required step, not optional.

Review package includes:
- The validated summary
- The full `open_questions` list (so `human:director` sees what is unresolved)
- A clear instruction: *"To return with a correction: identify the specific field and the correct value."* — without this, a vague correction cannot be classified

Record `presented_at` at the time of delivery.

**Subtask 2 — Receive response.**

**Subtask 3 — Response classification:**

Classify before act:

| Classification | Condition | Action |
|---|---|---|
| `APPROVED` | Deliberate affirmation: "approved," "confirmed," "yes, that's correct" | Proceed to Subtask 5 |
| `UNCLEAR` | Ambiguous: "looks good to me," "mostly right," "sure," "fine" | See UNCLEAR handling below |
| `RETURNED` | Identifies specific field(s) and correct value(s) | Proceed to Subtask 4 |

**Minimum approval statement:** Valid affirmations: "approved," "confirmed," "yes, that's correct," or equivalent unambiguous language. "Looks good," "fine," "sure," "mostly right" are `UNCLEAR`, not `APPROVED`. This is a classification rule — not a judgment call.

**`UNCLEAR` handling:** Identify the single question that resolves the ambiguity. Re-present with that question. `presented_at` does not change. Return to Subtask 2.

**`RETURNED` — scope change detection (before applying any correction):** Check whether the corrected field's value was used to resolve a prior `BLOCKER` register entry. If yes, assess whether the correction invalidates that resolution before applying it. Example: removing the *static* constraint re-opens the Workers/Pages deployment question. This is a targeted register check — not a full Task 1.2 re-run.

**Subtask 4 — Apply corrections:**

Classify each correction before application:
- **Value correction** — a change to an existing field's value: apply directly; update `project-manifest.traceability.yaml` for the changed field
- **Scope addition** — new content not present in the manifest (not a correction to an existing value): route through a lightweight mini Task 1.1–1.3 cycle before the manifest is updated. Do not apply scope additions in the same pass as value corrections.

After corrections, re-run the self-check against changed fields and any fields that depend on them. Full self-check only if a structurally significant field changed (e.g., `tech_stack`, `deployment_target`, `human_actors`).

**Correction loop health checks:**
- If the same field is corrected twice: flag `UNSTABLE-FIELD`; request `human:director` make a single definitive statement about that specific field before re-presenting the full manifest
- After three correction cycles without approval: surface the loop pattern explicitly to `human:director` — name which cycles have occurred and ask what is preventing approval. Do not continue silent cycling.

**Re-presentation format (after each correction pass):** Include a change summary naming, for each corrected field: the field name, the previous value, and the corrected value. This allows `human:director` to confirm the correction was applied without re-reading unchanged content.

Return to Subtask 1 with the corrected draft.

**Subtask 5 — Record approval:**

- Record the approval action in the audit log. Reference the audit log specification by file path — do not define the entry format inline. Inline formats drift from the canonical schema.
- Set `status` to `APPROVED`
- Set `approved_at` to the datetime of the **human approval action** — the datetime of `human:director`'s response, not the executor's processing timestamp. In asynchronous workflows these are distinct events; the human's timestamp is authoritative.
- Set `approved_by` to the name of the `human:director` actor as recorded in `human_actors`
- Set `approval_statement` to the verbatim words of `human:director`'s approval response, minimum 5 words. Must be a direct quotation — not a template phrase generated by the executor.

**Post-approval immutability:** Once `status: APPROVED` is set, neither `project-manifest.yaml` nor `project-manifest.traceability.yaml` may be modified. Any post-approval correction requires returning to `DRAFT` status and completing a full Task 1.5 re-run.

**This task may loop** through Subtasks 1–4. Exit condition: explicit `APPROVED` status with all Subtask 5 steps complete.

**Done when:** `status = APPROVED`, `approved_at` (human action timestamp), `approved_by`, and `approval_statement` are all set and consistent with the `human_actors` record, the approval action is recorded in the audit log, and neither the manifest nor its traceability record has been modified after the approval was recorded

***

## Items to Flag for Higher-Level Consideration

These elements emerged from detailing Step 1 but do not belong within Step 1's policy. They are cross-cutting concerns that likely appear in multiple steps.

**F1 — The No-Invention Invariant**
The constraint that no output field value may be invented — everything must trace to a source — is not unique to Step 1. It applies wherever structured output is produced from human-provided or structured input. This belongs as a framework-level constraint referenced by step policies, not defined within them.

**F2 — The Gap Classification Taxonomy**
The `BLOCKER` / `WARNING` / `INFO` classification system is reusable. Step 2 will need to classify gaps in the tech stack declaration against environment contract fields. The same taxonomy applies. Define it once at framework level (see FC-2).

**F3 — The Clarification Protocol**
The rules for how to request clarification from a human — one question per item, record question and answer with timestamps, attribution — are not Step 1-specific. Any step that encounters a blocking gap and has a human feedback channel will need the same protocol. Define once.

**F4 — The Human Approval Record Pattern**
The requirement that a human approval is recorded with timestamp, attribution, and an action reference (not just a field value) appears in Step 1 and will appear in Step 5. The mechanism for recording human decisions — the what, when, and who — belongs at framework level.

**F5 — The Source Traceability Record**
The companion record that maps every output field to its input source is a pattern that will likely appear wherever structured transformation occurs (brief → manifest, manifest → environment contract). The format and retention rules should be defined at framework level so every step applies them consistently.
# Framework Cross-Cutting Policies

**Version:** 0.2 — Draft
**Scope:** Bootstrap phase. Applies to all six step policies. Will be confirmed against delivery lifecycle policies before finalisation.
**Status:** Awaiting review

**Changelog — v0.2:**
Updates from Step 1 bootstrap session analysis (Tasks 1.2–1.5):

| Change | Policy affected | Source |
|---|---|---|
| Gate 3 (required field validity) documented as a distinct, independent gate alongside Gates 1 and 2. The `appetite` case demonstrates a required field can fail Gate 3 while returning NO on Gate 1 — Gate 2-only classification misses it. | FC-2 | Task 1.2 Subtask 1 |
| `POTENTIAL-CONTRADICTION` added as a WARNING-level pre-flag for domain-knowledge-dependent contradictions. Not all contradictions are detectable without domain expertise. | FC-2 | Task 1.2 Subtask 3 |
| Parenthetical retrieval instructions explicitly permitted within the 25-word question rule. Single-sentence retrieval instructions are not compound questions. | FC-3 | Task 1.3 Subtask 1 |
| `DECISION-REQUIRED` scoped out of FC-3. FC-3 resolves missing declared information; it cannot resolve undecided intent. | FC-3 | Task 1.3 Subtask 3 |
| "One question per gap; all questions delivered in one batch" clarified. Prior wording "one question per item, not a consolidated list" was ambiguous. | FC-3 | Task 1.3 Subtask 2 |
| Review record (`RR-xx`) defined as a distinct FC-4 Tier 1 artefact series, separate from `CE-xx`. Document taxonomy updated accordingly. | FC-4 | Task 1.5 Subtask 2 |
| `approvalstatement` (verbatim, minimum 5 words) added as a required field in the Tier 1 audit log entry. | FC-4 | Task 1.5 Subtask 5 |
| `approvedat` explicitly defined as the human action timestamp, not the executor processing timestamp. | FC-4 | Task 1.5 Subtask 5 |
| Two new `source_type` values added to FC-5: `correction` and `superseded_by` (implicit link field for correction chains). | FC-5 | Task 1.5 Subtask 4 |
| Post-approval immutability explicitly extended to the companion traceability record, not just the primary document. | FC-5 | Task 1.5 Subtask 5 |
| FC-8 document taxonomy extended to distinguish CE, RR, and CR artefact series produced across Steps 1–6. | FC-8 | Task 1.3, Task 1.5 |
| `gap_type` added as a required field in the `open_questions` schema and register: `ABSENT`, `AMBIGUOUS-INCOMPLETE`, `AMBIGUOUS-FORMAT`, `CONTRADICTION`, `SCHEMA-GAP`. | FC-2, FC-8 | CC-03 |
| `linked_questions` added as a required field in the `open_questions` schema and register — machine-readable array for linked/dependent entries. | FC-2, FC-8 | CC-04 |
| `schema_gap_flag` added as an optional field in the `open_questions` schema and register — boolean, with optional `candidate_field` for manifest template feedback loop. | FC-2, FC-8 | CC-05 |
| `POTENTIAL-CONTRADICTION` escalation path added: if the contradiction is confirmed during a clarification exchange, the entry is reclassified `BLOCKING` and FC-3 is invoked. | FC-2 | CC-02 |
| `DECISION-REQUIRED` formalised as a third response classification alongside `RESOLVED` and `CONFIRMED-UNKNOWN`. When returned, the register entry remains `BLOCKING`, a decision-request record is created, and the step enters `AWAITING-DECISION` state. | FC-3 | CC-07 |
| Response format guidance added to FC-3: the clarification exchange asks `human:director` to respond per-question, referencing the question number. | FC-3 | CC-08 |
| **FC-9 — Human Decision Support Protocol** added as a new named policy. Governs the `DECISION_REQUIRED` path: trigger condition (FC-3 vs FC-9 boundary), decision support package format, DR artefact schema, process state, unblock conditions (`DECISION_MADE` / `DEFERRED` / `UNCLEAR`), and executor boundaries. Resolves UQ-03. | FC-9 (new) | UQ-03 |
| FC-9 (Bootstrap Lifecycle State Machine) renumbered to **FC-10**. | FC-10 | UQ-03 |
| FC-3 DECISION-REQUIRED section slimmed to a cross-reference: FC-9 is invoked when `DECISION_REQUIRED` is returned; the mechanism is no longer defined inline in FC-3. | FC-3 | UQ-03 |
| FC-2 resolution statuses: `AWAITING_DECISION` added as a formal intermediate status for BLOCKER entries awaiting a human decision under FC-9. | FC-2 | UQ-03 |
| DR artefact series (`DR-xx`) added to the document taxonomy in FC-4 and FC-8. Filed at `.framework/decisions/`. | FC-4, FC-8 | UQ-03 |
| FC-8 register schema: `decision_request_ref` added as an optional field, populated when `resolution_status: AWAITING_DECISION`. | FC-8 | UQ-03 |
| FC-8 carry-forward rules: explicit rule added for `AWAITING_DECISION` entries at step handoff. | FC-8 | UQ-03 |

***

## Purpose

These ten policies settle the cross-cutting behavioural contracts that every bootstrap step and every agent operating within it must implement consistently. They are not step-specific — they are the shared rules that make the step policies coherent as a system rather than a collection of independent documents.

Each policy records: the decision options considered, the decision made with rationale, and the specific rule or format it produces. The rationale is on record per T4 — not just the decision.

***

## FC-1 — The No-Invention Invariant

### Context

Steps 1, 2, 3, and 4 all produce structured output documents from human-provided or prior-step input. In every case, the step policies state that output values must not be invented — they must trace to a specific input. This constraint is the most fundamental quality rule in the bootstrap phase: a manifest with a silently assumed value, a contract with an invented version number, or a pattern with fabricated evidence each introduce errors that propagate to every downstream step that consumes them.

The constraint has been stated consistently but informally across the step policies. It needs a single, testable definition that every verifier applies uniformly.

### Decision Options

**A — Guideline:** Document as a principle; leave enforcement to reviewer judgment.
**B — Hard constraint with companion traceability record:** Every substantive output field value must have a corresponding entry in a companion record identifying its source. The verifier tests this explicitly. A field with no traceability entry fails the review.
**C — Schema-embedded source fields:** Add a `_source` sub-field to every substantive field in every output document, making traceability part of the document schema itself.

### Decision: Option B

Option A is insufficient — P3 states that safety rules are built into how the system works, not into policies and promises. A guideline without a test is a promise.
Option C is structurally clean but imposes significant schema complexity across every output document. It conflates the primary document (the artefact) with its provenance record. These are different concerns and should remain separate.
Option B keeps the primary documents clean while making traceability independently verifiable. The companion record is the evidence layer — it is produced alongside the primary document, reviewed as part of the step's verification, and retained as proof.

### The Rule

**Definition of invention:** A value is invented if it cannot be found in a specific, named element of the step's valid inputs — including the raw brief, a recorded clarification answer, a prior step output field, the toolkit's seeding resources, or a documented derivation rule (e.g., `project_id` derived from `project_name` by a named transformation).

**The companion traceability record:**
- Produced alongside the primary output document, not after it — field by field during drafting
- Filed at `[project-root]/.framework/traceability/[step-output-name].traceability.md`
- Schema per entry:

| Field | Requirement | Format |
|---|---|---|
| `output_field` | REQUIRED | Exact field name as it appears in the primary document |
| `value_summary` | REQUIRED | First 20 characters of the value, or a unique identifier if the value is a list |
| `source_type` | REQUIRED | One of: `brief`, `clarification_answer`, `manifest_field`, `contract_field`, `seeding_resource`, `derivation_rule` |
| `source_reference` | REQUIRED | Specific enough to locate: paragraph in brief, clarification question ID and date, named field in named document, named seeding resource entry, or derivation rule name |

**Test applied by every verifier:**
1. Does a traceability record exist for this output document?
2. Is there an entry for every substantive non-empty field?
3. Is the `source_reference` specific enough to be independently located?
4. Does the value in the primary document actually match the named source?

Failure on any of the four tests is a `FAIL` verdict for the step — not a finding requiring revision. The no-invention constraint is a blocking quality gate, not a warning.

**Permitted derivations (not invention):**
- `project_id` derived from `project_name` by the kebab-case transformation rule — record as `derivation_rule: kebab_case_transform`
- A composite verification meta-pattern derived from two named seeding entries — record both entries in `source_reference`
- A field populated as `none stated` or `[]` because the input genuinely contained no relevant information — this is not invention; record as `source_type: brief`, `source_reference: "not present in input"`

***

## FC-2 — Gap Classification Taxonomy

### Context

Steps 1, 2, and 4 each classify gaps in their input information. Step 3 does so implicitly. The taxonomy used has been broadly consistent — BLOCKING, WARNING, LOW_RISK — but without a single definition document, each step is free to apply different thresholds. A gap classified as WARNING in Step 1 may be BLOCKING in Step 2's context. The carry-forward protocol (FC-8) requires a stable shared vocabulary.

### Decision Options

**A — Two-tier:** BLOCKING / OPEN_QUESTION — simple, binary, but loses the quality-impact signal
**B — Three-tier:** BLOCKING / WARNING / LOW_RISK — distinguishes "will affect downstream quality" from "negligible downstream impact"
**C — Four-tier:** BLOCKING / WARNING / LOW_RISK / INFORMATIONAL — adds a tier for gaps that are noted purely for completeness

### Decision: Option B

Option A loses a signal that is genuinely useful — a missing constraints list (WARNING) and a missing reference example (LOW_RISK) are both non-blocking but have very different downstream consequences. Collapsing them erases that distinction.
Option C adds a tier with no clear decision boundary between LOW_RISK and INFORMATIONAL. If something is truly informational, it is not a gap.
Option B is the right balance. Three tiers maps cleanly to three decisions: stop and resolve (BLOCKING); proceed and note for the next human gate (WARNING); proceed and note for completeness (LOW_RISK).

### The Rule

**Primary classification (live status):**

| Classification | Definition | Behaviour |
|---|---|---|
| `BLOCKING` | The step cannot produce a valid output without resolving this gap. Getting it wrong, or proceeding without it, will cause a downstream step to fail. | Step pauses. FC-3 (Clarification Protocol) is invoked. Step resumes only after resolution. |
| `WARNING` | The step can produce a valid output without this information, but the output will be of reduced quality with a known, specific downstream impact. | Step proceeds. Gap is recorded in `open_questions`. Flagged at next human gate. |
| `LOW_RISK` | The step can produce a valid output without this information. Downstream impact is negligible or zero. | Step proceeds. Gap is recorded in `open_questions` for completeness. Not flagged specially at human gates. |

**Classification test — applied to every gap:**
> *"Would proceeding without this information, or getting it wrong, cause a subsequent step to fail or produce a materially incorrect output?"*
> - YES → `BLOCKING`
> - NO → apply second test: *"Does the absence of this information have a known, specific impact on the quality of any downstream output?"*
>   - YES → `WARNING`
>   - NO → `LOW_RISK`

**Gate 3 — Required Field Validity (independent gate):**

Gate 3 is a distinct, independent field-level gate applied in addition to Gates 1 and 2. It must not be conflated with either:

- **Gate 1** tests whether a field value is *present*.
- **Gate 2** tests whether a field value is *classifiable* (BLOCKING / WARNING / LOW_RISK).
- **Gate 3** tests whether a *required field* that is present is *valid* — i.e., whether the value supplied actually satisfies the field's type, domain, and constraint requirements.

A required field can fail Gate 3 while returning NO on Gate 1 (because a value was provided) and appearing resolved at Gate 2. The `appetite` case is the canonical example: a value was present and classified, but the value itself violated the required field's domain constraints. Gate 2-only classification misses this category of failure.

Gate 3 is invoked for every field flagged `REQUIRED` after Gates 1 and 2 pass. Failure at Gate 3 is classified `BLOCKING` and invokes FC-3.

**`POTENTIAL-CONTRADICTION` pre-flag:**

`POTENTIAL-CONTRADICTION` is a WARNING-level pre-flag signalling that two or more field values — or a field value and known domain knowledge — are in apparent conflict, but resolving the conflict requires domain expertise the step does not hold.

Behaviour:
- The contradiction is flagged in `open_questions` with classification `WARNING`, `gap_type: CONTRADICTION`, and `flags: POTENTIAL-CONTRADICTION`.
- The step does not attempt to resolve the contradiction autonomously.
- The flag is surfaced at the next human gate for `human:director` to adjudicate.
- If `human:director` **confirms** the contradiction during a clarification exchange, the entry is immediately reclassified `BLOCKING` and the FC-3 clarification protocol is invoked to obtain the authoritative value. The confirmed-contradiction entry does not remain at WARNING.
- If `human:director` **resolves** the contradiction (confirms one value is correct), the entry is updated to `RESOLVED` and the winning value is written to the primary document with `source_type: clarification_answer`.

This flag exists because not all contradictions are detectable without domain expertise. The Workers/static case is the reference: a declared value may be technically valid in isolation while being inconsistent with a deployment context that only a domain expert can evaluate. Silently choosing one value over another would violate FC-1.

**Resolution statuses (terminal and intermediate states of a BLOCKING gap):**

| Status | Meaning |
|---|---|
| `BLOCKING_RESOLVED` | A BLOCKING gap that was resolved through the clarification protocol. The resolved value is now in the step output. |
| `BLOCKING_CONFIRMED_UNKNOWN` | A BLOCKING gap where `human:director` confirmed they cannot provide the information. Downgraded to `OPEN_QUESTION` with this status recorded. The step output documents it as an open question rather than an empty field. |
| `AWAITING_DECISION` | A BLOCKING gap where `human:director` has not yet made the underlying decision. An FC-9 Decision Request record (`DR-xx`) is created and the step is blocked pending `human:director`'s decision. This is an intermediate state — it resolves to `BLOCKING_RESOLVED` when a decision is made, or `BLOCKING_CONFIRMED_UNKNOWN` when the decision is explicitly deferred. Governed by FC-9. |

**`open_questions` entry schema** — used wherever gaps are documented in step outputs:

| Field | Requirement | Format |
|---|---|---|
| `question_id` | REQUIRED | `OQ-[step]-[sequence]`, e.g., `OQ-1-03` |
| `field` | REQUIRED | The output field this gap relates to |
| `gap` | REQUIRED | What is missing or ambiguous — one sentence |
| `gap_type` | REQUIRED | One of: `ABSENT` (value not present), `AMBIGUOUS-INCOMPLETE` (partial information provided), `AMBIGUOUS-FORMAT` (information present but in wrong form), `CONTRADICTION` (conflicting values), `SCHEMA-GAP` (no manifest field exists to hold this information) |
| `impact` | REQUIRED | What fails or degrades downstream if this remains unresolved |
| `classification` | REQUIRED | `WARNING` or `LOW_RISK` for open questions in a completed step output; `BLOCKING_CONFIRMED_UNKNOWN` for confirmed unknowns |
| `flags` | OPTIONAL | `POTENTIAL-CONTRADICTION` where applicable |
| `linked_questions` | REQUIRED | Machine-readable array of `question_id` values for related or dependent entries — `[]` if none. Task 1.3 queries this field to detect consolidation opportunities and propagate resolutions. |
| `schema_gap_flag` | OPTIONAL | `true` if this gap represents information that has no corresponding manifest schema field. When set, `candidate_field` (optional string) names the proposed new field for manifest template evolution. |
| `source_step` | REQUIRED | Which step raised this question |
| `resolution_status` | REQUIRED | `UNRESOLVED` \| `RESOLVED` \| `CONFIRMED_UNKNOWN` \| `AWAITING_DECISION` |}

***

## FC-3 — Clarification Protocol

### Context

Steps 1 and 2 each have a conditional task for resolving BLOCKING gaps through a question-and-answer exchange with `human:director`. Currently described informally — "formulate a specific question," "record the answer." The protocol needs to define: how questions are grouped and presented, the record format, and what happens when the exchange does not resolve the gap.

### Decision Options

**A — One question per exchange, sequential:** Single question each time, step blocks between each exchange. Maximally safe; potentially many round trips.
**B — All blocking gaps in one batch, single exchange:** All gaps presented at once; step blocks until all answered. Fewest round trips; may overwhelm the human if many gaps.
**C — Grouped by domain, maximum 3 per exchange:** Groups related questions; limits cognitive load per exchange; may require two exchanges if more than 3 blocking gaps.

### Decision: Option B with a presentation structure from Option C

In bootstrapping, blocking gaps cluster around missing required fields in the project brief. A well-formed brief will produce zero blocking gaps; an incomplete brief may produce 3–6. Rare to exceed 6. A single batched exchange is efficient and minimises human interruption. The presentation structure from Option C — grouped by domain, clearly formatted — makes a batch of several questions manageable. The "maximum 3 per exchange" limit from Option C is unnecessary given that batching all gaps into one exchange is preferred — applying a limit would create artificial rounds.

### The Rule

**Question formulation:**
Each question must be:
- One sentence, maximum 25 words
- Specific to a single missing field — not compound ("What is the tech stack and where is it deployed?" is two questions)
- Named by field: "Which version of AstroJS are you using?" not "What's the tech stack?"
- Accompanied by a one-sentence impact statement: "This is required before the environment contract can be written."

*Parenthetical retrieval instructions permitted:* A question may include a brief parenthetical instruction directing the human to a specific source ("see the brief, paragraph 3") without this constituting a compound question. Such instructions aid efficient retrieval and do not add a second question. The 25-word limit applies to the question sentence; a retrieval parenthetical is excluded from the word count provided it is a single clause of no more than 8 words.

**Batching — one question per gap; all questions in one batch:**
Each BLOCKING gap produces exactly one question. All questions for a single clarification exchange are delivered together in one batch — not sequentially, not one at a time. "One question per gap" means a single question is formulated for each distinct gap; it does not mean questions are submitted one at a time. Grouping for presentation achieves clarity within the batch; it does not reduce the batch to a single question.

**Grouping for presentation:**
Questions within the batch are grouped by domain in presentation order:

1. Project identity gaps (project name, description)
2. Technical gaps (tech stack, deployment, environment)
3. Governance gaps (human actors, roles)
4. Scope gaps (appetite, out-of-scope, constraints)

Within each group, questions are listed as a numbered list. The group heading names the domain.

**Scope of FC-3 — what the clarification protocol does and does not resolve:**

FC-3 resolves *missing declared information* — values that `human:director` has decided but not yet communicated. It does not, and cannot, resolve *undecided intent*.

A gap is `DECISION-REQUIRED` when `human:director` has not yet made the underlying decision. `DECISION-REQUIRED` is a formal third response classification alongside `RESOLVED` and `CONFIRMED-UNKNOWN`. When a clarification response returns `DECISION-REQUIRED`, **FC-9 — Human Decision Support Protocol** is invoked immediately. FC-3's role ends at classifying the response; FC-9 governs all subsequent behaviour including the Decision Request record, process state, unblock conditions, and executor boundaries.

`DECISION-REQUIRED` gaps must also be surfaced explicitly at the next human gate, with the framing that a decision is required before the step can proceed — not a clarification of something already decided.

**The clarification exchange record** — filed at `[project-root]/.framework/clarifications/step-[n]-clarification-[sequence].md`:

| Field | Requirement | Format |
|---|---|---|
| `exchange_id` | REQUIRED | `CE-[step]-[sequence]`, e.g., `CE-1-01` |
| `step` | REQUIRED | Which step initiated this exchange |
| `initiated_at` | REQUIRED | ISO 8601 datetime with timezone |
| `questions` | REQUIRED | List of question objects; each with: `question_id`, `field`, `question_text`, `impact_statement` |
| `responded_at` | REQUIRED once answered | ISO 8601 datetime with timezone |
| `responses` | REQUIRED once answered | List of response objects; each with: `question_id`, `response_text`, `resolution` (`RESOLVED` \| `CONFIRMED_UNKNOWN` \| `DECISION_REQUIRED`) |

**Expected response format:**
`human:director` is asked to respond per-question, referencing the question number (e.g., "Q1: ...", "Q2: ..."). This is processability guidance, not a hard constraint on how the human writes — but responses that do not reference question numbers require the executor to map each response to a question before updating the register, which must be done before any register entry is updated.

**Behaviour after the exchange:**
- `RESOLVED`: the response provides the required value. The value is written to the step output with `source_type: clarification_answer` in the traceability record, citing the `exchange_id` and `question_id`.
- `CONFIRMED_UNKNOWN`: `human:director` has confirmed they cannot provide this information. The gap is reclassified to `BLOCKING_CONFIRMED_UNKNOWN` and downgraded to an `OPEN_QUESTION` entry in the step output. The step proceeds without this value.
- `DECISION_REQUIRED`: `human:director` has not yet made the underlying decision. **FC-9 — Human Decision Support Protocol** is invoked immediately. See *Scope of FC-3* above.

**What the exchange does not do:**
- Does not ask for design preferences ("What colour scheme do you prefer?")
- Does not ask scope-setting questions ("Should we include a blog?") — scope is human:director's domain, not the step's
- Does not offer options ("Should it be AstroJS or Next.js?") — the clarification protocol resolves missing declared information, not undecided information. Undecided choices are surfaced as `DECISION-REQUIRED` and handled by FC-9
- Does not attempt to resolve `DECISION-REQUIRED` gaps — when `DECISION-REQUIRED` is returned, FC-9 Human Decision Support Protocol is invoked

**No response handling:**
If `human:director` does not respond, the step remains blocked. There is no timeout that allows the step to proceed with assumptions. This is a framework-level timing concern flagged as F28 — the present policy records that blocking is the correct behaviour and defers the response-time SLA to framework level.

***

## FC-4 — Human Approval Record Pattern

### Context

Step 1 requires `human:director` to approve the project manifest. Step 6 requires `human:director` to approve readiness for delivery. Both involve a human making a conscious decision. Both must be on record. But they are not the same kind of decision — Step 1 is a confirmation of accuracy; Step 6 is an irreversible lifecycle gate. The recording mechanism should reflect this difference.

### Decision Options

**A — Field-in-document only:** Status, approved_by, and approved_at fields in the primary document. Simple; the document is self-describing.
**B — Separate decision record:** A dedicated record document produced at the moment of decision. Heavier; appropriate for high-stakes decisions.
**C — Audit log entry only:** The human action is recorded in the audit log with attribution and timestamp. Machine-readable; not human-navigable as a primary reference.
**D — Field-in-document + audit log entry (Tier 1):** For standard approvals — confirmation that a document accurately represents intent.
**E — Separate decision record + audit log entry (Tier 2):** For one-way decisions — irreversible lifecycle gates.

### Decision: Options D and E as a two-tier pattern

The distinction between a "confirmation of accuracy" and a "one-way decision" is real and significant. Conflating them — either by making all approvals heavyweight (B everywhere) or all approvals lightweight (A everywhere) — loses that distinction. Two tiers is the right answer.

### Document Artefact Series

The approval and review process across Steps 1–6 produces three distinct document artefact series. These series are independent and must not be conflated:

| Series | Prefix | Purpose | Produced by |
|---|---|---|---|
| Clarification Exchange | `CE-xx` | Records a question-and-answer exchange initiated to resolve BLOCKING gaps. Defined in FC-3. | FC-3 clarification protocol |
| Review Record | `RR-xx` | Records the outcome of a verifier's review of a primary document — verdict, findings, and disposition. Tier 1 artefact. | Verifier role at each step |
| Correction Record | `CR-xx` | Records a correction applied to an approved document — what was wrong, what was corrected, and the correction source. Defined in FC-5. | Executor role when correcting an approved output |
| Decision Request | `DR-xx` | Records a structured decision support package presented to `human:director` when a BLOCKING gap returns `DECISION_REQUIRED` from FC-3. Defined in FC-9. | FC-9 decision support protocol |

Each series has its own schema (defined in the respective policy or step policy). Audit log entries reference artefacts by series prefix and sequence number (e.g., `RR-1-02`, `CE-2-01`, `CR-1-01`, `DR-1-01`).

### The Rule

**Tier 1 — Standard Approval** (used in Step 1 and Step 2):

*Applied when:* A document is being confirmed as accurate by the party whose intent it represents. The decision is reversible — the document can be revised and re-approved.

*Fields required in the primary document:*

| Field | Requirement | Format |
|---|---|---|
| `status` | REQUIRED | `APPROVED` — set only by the approval action, never by the producer |
| `approved_by` | REQUIRED | Name of the approving human — must match a named `human:director` entry |
| `approved_at` | REQUIRED | ISO 8601 datetime with timezone — timestamp of the **human approval action**, not the executor's processing timestamp. In asynchronous workflows, these are distinct events; the human action timestamp is authoritative. |
| `approval_statement` | REQUIRED | Verbatim statement from the approving human, minimum 5 words. Not a template phrase — must be authored by the human at the time of approval. |

*Audit log entry required:*

| Field | Requirement |
|---|---|
| `action_type` | `document_approved` |
| `document` | Path to the approved document |
| `actor` | `approved_by` value |
| `timestamp` | `approved_at` value — the human action timestamp |
| `approval_statement` | Verbatim, reproduced from the primary document field |
| `document_version` | The version or status of the document at time of approval |
| `review_record_id` | ID of the associated `RR-xx` review record (required if a review was conducted before approval) |

*Review record (`RR-xx`) produced at Tier 1:*
Before a Tier 1 approval is made, a verifier produces a review record documenting their findings. The `RR-xx` record is a distinct Tier 1 artefact — it is not embedded in the primary document and is not replaced by the audit log entry. It captures:
- The verifier's identity
- The review verdict (`PASS` / `PASS_WITH_FINDINGS` / `FAIL`)
- Findings (if any), each referencing the specific field and the nature of the issue
- The disposition (approved as-is, or returned for revision)

**Tier 2 — One-Way Decision** (used in Step 6):

*Applied when:* A human is making an irreversible lifecycle decision. The decision cannot be undone without restarting the phase.

*Requirements beyond Tier 1:*
- A **separate decision record document** is produced (not a status field in the primary document)
- The decision record is **immutable** after creation (enforcement mechanism per F26 — deferred to framework level; policy requires immutability, mechanism TBD)
- An **`approved_statement`** is required — written in first person by the decision-maker, minimum 10 words, not a template phrase
- For `PASS_WITH_GAPS` decisions: **gap acknowledgement entries** are required before the decision is available
- The decision record schema is defined in full in the Step 6 policy

*What both tiers share:*
- Attribution to a named human in the `human_actors` list — not a role title, a named person
- A timestamp that is after the document's creation timestamp — a decision cannot predate the thing it decides on
- `approved_at` is always the **human action timestamp** — in asynchronous workflows, the time the human performed the approval action, not the time the executor recorded or processed it
- An audit log entry that is independent of the document field — the audit log entry is the proof the decision was made; the document field is the state indicator

***

## FC-5 — Source Traceability Record

### Context

Defined as part of FC-1 (the companion record that maps output field values to their input sources). This policy specifies the format, retention, and operational rules in full.

### Decision Options

**A — Inline source citation in the primary document:** `_source` fields alongside each value.
**B — Separate companion file per step output.**
**C — Entries in the audit log.**

### Decision: Option B

Covered in FC-1 rationale. Companion file keeps primary documents clean while making traceability independently verifiable.

### The Rule

**Companion file location:**
`[project-root]/.framework/traceability/[step-output-filename].traceability.md`

Examples:
- `project-manifest.traceability.md` (Step 1)
- `environment-contract.traceability.md` (Step 2)
- `[RoleName].agent.traceability.md` for each role definition (Step 3)
- `[pattern_id].traceability.md` for each pattern entry (Step 4)

**Production timing:**
The traceability record is produced **field by field during drafting** — not after the primary document is complete. This is the operational enforcement of FC-1: if a field cannot be given a traceability entry at the time of writing, it should not be written into the primary document yet.

**Retention:**
Traceability records are permanent. They are not deleted when a document is approved or superseded. They are the evidence that the no-invention constraint was met at the time of production.

**Post-approval immutability:**
Once a primary document has received a Tier 1 or Tier 2 approval, both the primary document **and its companion traceability record** are immutable. Modifying the traceability record post-approval is functionally equivalent to modifying the manifest — it is a prohibited action regardless of whether the primary document itself is changed. Any post-approval correction must produce a `CR-xx` correction record (see below) and a new traceability entry; the original entries are not modified.

**Schema** — each entry is one row:

```
| output_field | value_summary | source_type | source_reference |
```

- `output_field`: exact field name from the primary document schema
- `value_summary`: first 30 characters of the field value, or `[list: N entries]` for list fields
- `source_type`: one of `brief` | `clarification_answer` | `manifest_field` | `contract_field` | `seeding_resource` | `derivation_rule` | `not_present_in_input` | `correction` | `superseded_by`
- `source_reference`: specific locator — paragraph identifier, clarification exchange ID + question ID, field path (`manifest.tech_stack[0]`), named seeding resource entry ID, derivation rule name, or correction record ID (`CR-xx`)

**`source_type` values — full reference:**

| Value | Usage |
|---|---|
| `brief` | Value sourced from the human-provided project brief |
| `clarification_answer` | Value sourced from a clarification exchange response |
| `manifest_field` | Value sourced from a named field in the project manifest |
| `contract_field` | Value sourced from a named field in the environment contract |
| `seeding_resource` | Value sourced from a named toolkit seeding resource entry |
| `derivation_rule` | Value derived by a named derivation rule (e.g., kebab-case transform) |
| `not_present_in_input` | Required field with no value present in any valid input |
| `correction` | Value introduced by a post-approval correction. `source_reference` must cite the `CR-xx` correction record. |
| `superseded_by` | The original value in this field has been superseded by a correction. `source_reference` must cite the `CR-xx` correction record that replaced it. Used to mark the original entry in a correction chain — not to replace it. |

**Correction chains:**
When a post-approval correction applies to a field already in the traceability record:
1. The original entry is annotated with `source_type: superseded_by` and `source_reference: CR-xx` — the original entry is **not deleted**.
2. A new entry is appended with `source_type: correction` and `source_reference: CR-xx`.
3. The `CR-xx` correction record links back to the original traceability entry and the original primary document field value.

**What the verifier checks:**
1. The companion file exists at the canonical path
2. Every substantive non-empty field in the primary document has an entry
3. `source_reference` is specific — not "from the brief" but "from the brief, paragraph 2, sentence 1"
4. The value in the primary document is consistent with what the named source actually says

**What the traceability record does not contain:**
- Governance metadata (approval status, version history)
- Values from fields that are `none stated` or `[]` — these are recorded as `source_type: not_present_in_input` only if the field is REQUIRED; OPTIONAL empty fields need no traceability entry

***

## FC-6 — Verifiability Standard

### Context

Step 2 introduced the rule that every claim in the environment contract must be independently testable. Step 5 confirmed this in the infrastructure and smoke test checks. The standard needs a single, self-applying definition — one that a verifier can apply without making a judgment call.

### Decision Options

**A — Subjective standard:** The verifier judges whether a claim seems verifiable based on experience.
**B — Objective test:** A claim is verifiable if and only if it specifies one of a named set of evidence types that produce an unambiguous pass/fail result.
**C — Predefined field-type checklist:** Certain field types are always verifiable (commands, URLs); others always require review.

### Decision: Option B

Option A requires judgment per field — which defeats the purpose of a standard. Two verifiers would reach different conclusions. Option C is useful but incomplete — it handles known field types but not novel ones. Option B is self-applying and exhaustive: if a claim doesn't name a command, file path, URL, or observable state, it fails the test. Period.

### The Rule

**The verifiability test:**
A claim is verifiable if and only if it specifies at least one of:

| Evidence type | Definition | Example |
|---|---|---|
| **Executable command** | A named command that can be run in the declared environment, producing an exit code or output that confirms or refutes the claim | `pnpm build` — exit code 0 confirms build succeeds |
| **Named file at a known path** | A file at a specific path whose existence, content, or state confirms the claim | `astro.config.mjs` — readable and contains `output: 'static'` |
| **URL with expected response** | A URL that returns a specific HTTP status or observable content when accessed | `https://petesplumbing.com.au` — returns HTTP 200 |
| **Observable system state** | A system condition that can be confirmed by reading a specific output — log entry, database record, process status | Audit log entry `task_created: smoke-01` readable by ID |

**Claims that fail the test — with examples:**

| Failing claim | Why it fails | Corrected form |
|---|---|---|
| `runtime: latest` | "latest" is not a version — no command confirms it | `runtime: 22.x` — confirmed by `node --version` |
| `build: fast` | "fast" has no measurable threshold | Remove; add to `performance.targets` with a measurable metric |
| `output: recommended` | "recommended" is not a value | `output_mode: static` — confirmed by reading `astro.config.mjs` |
| `deployment: production-ready` | No command confirms "production-ready" | Replace with specific deployment URL and verification command |
| `Lighthouse score: good` | "good" is not a threshold | `Lighthouse Performance: ≥ 90` — confirmed by `lighthouse-ci` command |

**Where this standard applies:**
- Step 2: every field in the environment contract
- Step 4: every claim in a pattern's `evidence` field (the evidence must be independently confirmable, not just asserted)
- Step 5: every check item in the bootstrap report (document checks, infrastructure checks, smoke test results)
- Delivery lifecycle: every proof template entry — a proof criterion that cannot be confirmed by the verifiability test is not a proof criterion

**Where this standard does not apply:**
- `open_questions` entries — these are gap records, not claims
- Narrative fields (`description`, `problem` in patterns) — these are explanatory text, not testable assertions
- `approved_statement` in the decision record — this is a human declaration, not a technical claim

***

## FC-7 — Producer/Verifier Separation Mechanism

### Context

T5 states no actor marks their own work. This appears in every step: the manifest drafter does not review the manifest; the contract author does not verify the contract; the pattern documenter does not review the pattern; the bootstrap report producer does not approve readiness. The principle is clear. What has not been defined is how the system enforces this structurally — not just as a policy instruction, but as something that cannot be bypassed.

### Decision Options

**A — Process enforcement only:** Policy states the rule; human or agent review catches violations.
**B — Identity check at submission:** The system checks reviewer identity against producer identity when a review is submitted; rejects submissions where they match.
**C — Role-based structural prevention:** Reviewer roles have a `never` list containing all documents the corresponding producer role writes — making the reviewer role structurally incapable of producing the document it reviews. Combined with: only the reviewer role can submit a review verdict for documents it reviews.
**D — Post-hoc audit detection:** Both production and review are attributed in the audit log; violations are detectable by inspection.

### Decision: Option C as the primary mechanism, Option D as the verification layer

Option A is not consistent with P3 — safety by design, not by policy. Option B is better but depends on the identity check being correctly implemented and not bypassable. Option D detects violations but doesn't prevent them. Option C is structural prevention — if the reviewer role cannot write the document it reviews, and only the reviewer role can submit a review verdict, then self-review is architecturally impossible. Option D provides independent confirmation that the structural prevention is working.

### The Rule

**The structural enforcement mechanism has three components:**

**Component 1 — Role capability bounds (design time):**
Every reviewer role definition must contain in its `never` list all document types produced by the role it reviews. This is verified in Step 3's set verification (Task 3.5, T5 compliance check).

Examples:
- The entity that reviews the environment contract must have `never` containing `environment-contract.md`
- The entity that reviews a pattern must have `never` containing pattern library entries
- The entity that reviews a role definition must have `never` containing `.agent.md` files

**Component 2 — Submission check (runtime):**
When a review verdict is submitted to the Nexus server, the server performs an identity check:
- Retrieve the production audit log entry for the document being reviewed
- Compare the producing identity to the submitting identity
- If they match: reject the submission with reason `T5_VIOLATION`; write a rejection audit entry

The identity comparison must be against the **structural role identity** — not a human name. If two different humans are both acting as the same role class, they are the same structural identity for T5 purposes. T5 requires structurally different roles, not just different people.

**Component 3 — Audit attribution (verification):**
Both the production event and the review verdict event are written to the audit log with attributed identities. The set verification check in Step 3 (Task 3.5) and the bootstrap report in Step 5 (Task 5.1, D4/D5) both inspect these entries. Any gap — a review event with no corresponding production attribution, or a review event whose attribution matches the production attribution — is a finding.

**The definition of "same identity" for T5:**
Two actors are the same identity if they share the same role class in the same project context. Two different instances of `PatternDocumenter` are the same T5 identity. A `PatternDocumenter` and a `PatternReviewer` are different T5 identities — this is the correct separation.

**The definition of "different identity":**
Producer and verifier are different identities if they are different role classes with non-overlapping write authority over the domain being reviewed. It is not sufficient that two actors have different names if they hold the same role class.

***

## FC-8 — Carry-Forward of Open Questions Between Steps

### Context

Step 1 produces `open_questions` entries in the project manifest. Step 2 explicitly reclassifies tech-stack-related open questions from Step 1 in the context of its own requirements — a WARNING gap about a missing version number from Step 1 may become BLOCKING in Step 2. Without a formal protocol, this reclassification happens ad hoc, entries may be duplicated or lost, and there is no single view of all unresolved gaps across the bootstrapping phase.

### Decision Options

**A — Each step independently identifies its gaps; no shared state.**
**B — A shared open questions register maintained throughout bootstrapping; each step reads, reclassifies, and adds to it.**
**C — Open questions are embedded only in the step that raised them; the next step reads the prior step's output and extracts relevant entries.**

### Decision: Option B

Option A produces duplicate identification work and creates inconsistency — the same gap identified independently in two steps may be described differently, making the bootstrap report harder to read. Option C works for adjacent steps (Step 2 reads Step 1's manifest) but breaks down for non-adjacent reclassifications. Option B provides a single, navigable record of all open gaps across the bootstrapping phase — which is exactly what `human:director` needs at Step 6 to make an informed decision.

### The Rule

**Document artefact taxonomy (bootstrap phase):**

The bootstrap phase produces the following named document artefact series. Steps 1–6 collectively generate artefacts across all series. The open questions register references artefacts by series prefix and sequence number.

| Series | Prefix | Filing location | Steps that produce |
|---|---|---|---|
| Clarification Exchange | `CE-[step]-[seq]` | `.framework/clarifications/` | 1, 2 (any step invoking FC-3) |
| Review Record | `RR-[step]-[seq]` | `.framework/reviews/` | 1, 2, 3, 4, 5 (any step with a verifier) |
| Correction Record | `CR-[step]-[seq]` | `.framework/corrections/` | Any step where a post-approval correction is applied |
| Decision Request | `DR-[step]-[seq]` | `.framework/decisions/` | Any step where `DECISION_REQUIRED` is returned from FC-3 |

These series are distinct. Artefacts must not be filed under the wrong prefix. The audit log references all three series by ID. FC-3 defines the CE schema; FC-4 defines the RR schema; FC-5 defines the CR schema and correction chain protocol.

**The open questions register:**
Filed at `[project-root]/.framework/open-questions-register.md`

Created in Step 1, Task 1.2 (Gap Classification). Persists throughout all six steps. Each step reads it at the start of its gap analysis task and writes to it when producing new open questions or reclassifying existing ones.

**Register entry schema:**

| Field | Requirement | Format |
|---|---|---|
| `question_id` | REQUIRED | `OQ-[step_raised]-[sequence]`, e.g., `OQ-1-03` — never changes after assignment |
| `field` | REQUIRED | The output field this question relates to, including the document it belongs to |
| `gap` | REQUIRED | What is missing or ambiguous — one sentence — never modified after first write |
| `gap_type` | REQUIRED | One of: `ABSENT`, `AMBIGUOUS-INCOMPLETE`, `AMBIGUOUS-FORMAT`, `CONTRADICTION`, `SCHEMA-GAP` — never modified after first write |
| `impact` | REQUIRED | What fails or degrades downstream — updated when a subsequent step provides a more specific impact |
| `raised_by_step` | REQUIRED | The step number that first identified this gap |
| `current_owner` | REQUIRED | The step number currently responsible for monitoring or resolving this question |
| `classification` | REQUIRED | `WARNING` \| `LOW_RISK` \| `BLOCKING_CONFIRMED_UNKNOWN` — updated when reclassified |
| `flags` | OPTIONAL | `POTENTIAL-CONTRADICTION` where applicable |
| `linked_questions` | REQUIRED | Machine-readable array of `question_id` values for related or dependent entries — `[]` if none. Immutable once set (new links are appended, not replaced). |
| `schema_gap_flag` | OPTIONAL | `true` if this entry represents information with no current manifest schema field. `candidate_field` (optional string) may be set to name the proposed field. |
| `decision_request_ref` | OPTIONAL | `DR-[step]-[seq]` — populated when `resolution_status: AWAITING_DECISION`. Links the register entry to its Decision Request record without embedding DR content in the register. |
| `resolution_status` | REQUIRED | `UNRESOLVED` \| `RESOLVED` \| `CONFIRMED_UNKNOWN` \| `AWAITING_DECISION` |
| `resolution_note` | Conditional | Required when `resolution_status: RESOLVED` — records what resolved it (clarification exchange ID, DR record ID, or "addressed in Step N output") |
| `last_updated_by_step` | REQUIRED | The step that last modified this entry |
| `last_updated_at` | REQUIRED | ISO 8601 datetime |

**Reclassification protocol:**
Each step, when beginning its gap analysis task, reads the register and:
1. Identifies entries owned by prior steps that are relevant to its work
2. For each relevant entry: applies the FC-2 classification test in its own context — the classification may change (a WARNING may become BLOCKING; a LOW_RISK may become WARNING; a BLOCKING_CONFIRMED_UNKNOWN may be resolved by a subsequent step's input)
3. Updates `classification`, `current_owner`, `impact`, `last_updated_by_step`, and `last_updated_at` if the classification changes
4. Does not change `question_id`, `gap`, or `raised_by_step` — these are immutable once set

**Reclassification from LOW_RISK / WARNING to BLOCKING:**
If a step reclassifies an existing open question to BLOCKING, the FC-3 clarification protocol is invoked immediately — even mid-step. This is consistent with L1 (speak up as soon as unsure). A gap that was LOW_RISK in Step 1 but is BLOCKING in Step 2 cannot wait until the next human gate.

**Carry-forward of `AWAITING_DECISION` entries:**
An entry with `resolution_status: AWAITING_DECISION` at a step handoff is carried to the next step with its status preserved — it is not downgraded, resolved, or removed. The receiving step must:
1. Assess whether the gap is still BLOCKER in its own context (a gap that was BLOCKER in Step 1 may be BLOCKER in Step 2 for different reasons)
2. If still BLOCKER and no decision has arrived: preserve `AWAITING_DECISION` status; update `current_owner` to the receiving step
3. If a decision has since arrived (DR record shows `resolution_status: DECISION_MADE` or `DEFERRED`): apply the resolution per the DR record and update the register entry accordingly
4. If no longer BLOCKER in the new step's context: reclassify per the FC-2 classification test and update `current_owner`; the `AWAITING_DECISION` state is not inherited if the gap is no longer blocking

FC-9 does not automatically re-invoke at each step handoff. The receiving step invokes FC-9 independently if and only if the gap remains BLOCKER and the underlying decision is still unmade.

**The register at Step 6:**
The bootstrap report (Step 5) includes the register's `UNRESOLVED` and `AWAITING_DECISION` entries in its gap list. Step 6 presents these to `human:director`. Gap acknowledgements in the Step 6 decision record reference `question_id` values from the register — not free-text descriptions. After Step 6 `APPROVED`, entries with `resolution_status: UNRESOLVED` that `human:director` acknowledged are updated to `resolution_status: ACCEPTED_AS_KNOWN_GAP`. Entries still in `AWAITING_DECISION` at Step 6 are treated as `CONFIRMED_UNKNOWN` unless `human:director` provides a decision at that gate.

***

## FC-9 — Human Decision Support Protocol

### Context

FC-3 governs clarification — it resolves missing declared information. Its explicit scope statement excludes undecided intent. When a clarification response returns `DECISION_REQUIRED`, FC-3's resolution loop cannot close: FC-3 resolves *missing declared information*; an unmade decision is not missing information — it is an unexercised judgment.

Extending FC-3 to cover decisions would require removing its integrity boundary, after which FC-3 would need internal logic to distinguish when to clarify versus when to support — recreating the design problem inside FC-3. A separate protocol is the correct solution, consistent with how FC-4 (approval) was kept separate from FC-3 (clarification) despite both being human interactions governed by distinct event types.

### The Core Distinction

| | FC-3 Clarification | FC-9 Decision Support |
|---|---|---|
| **Cause** | `human:director` has the information but didn't include it | `human:director` has not yet made the choice |
| **Example** | "What Node version are you running?" | "Have you decided between Formspree and a custom handler?" |
| **Executor's role** | Retrieve existing knowledge | Support a decision the human must make |
| **Block reason** | Missing data | Unmade decision |
| **Unblock condition** | `human:director` provides the value | `human:director` makes and states the decision |

### Trigger Condition — FC-9 vs FC-3

One test:

> *"Does `human:director` have this information available right now, and would stating it resolve the gap?"*
> - **YES → FC-3.** The gap is missing declared information. Ask.
> - **NO → FC-9.** The gap is an unmade decision. Support.

The trigger is `human:director`'s own response — not the executor's prior classification. FC-3 runs first. If the FC-3 response returns `DECISION_REQUIRED`, FC-9 is then invoked. FC-9 is never invoked before FC-3 is attempted.

### The Rule

**What the executor presents:**

When `DECISION_REQUIRED` is confirmed, the executor produces a structured decision support package with exactly four elements — no more, no fewer:

**1. Field and impact statement** — names the manifest field and why it is blocked:
> *"`integration_requirements.provider` — the form handler provider must be confirmed before the Step 2 integration contract can be written. Without it, the Step 2 executor cannot specify the submission endpoint, CORS configuration, or environment variable schema."*

**2. Options** — the available choices, drawn only from the executor's knowledge base or information already in the brief. No invented options. Each option includes a one-sentence description and a one-sentence implication.

**3. Decision instruction** — names exactly what response constitutes a usable decision:
> *"To unblock this: state which option you are selecting, or provide a different option not listed above. If you choose to defer, confirm explicitly — the field will be left empty and flagged as `CONFIRMED_UNKNOWN`."*

**4. No recommendation.** The executor does not recommend an option. Presenting options is support; recommending is scope-setting — it introduces executor preference into a human-owner judgment call.

**The Decision Request (`DR-xx`) record:**

Filed at: `[project-root]/.framework/decisions/DR-[step]-[seq].yaml`

| Field | Requirement | Format |
|---|---|---|
| `decision_request_id` | REQUIRED | `DR-[step]-[seq]`, e.g., `DR-1-01` |
| `step` | REQUIRED | Step that initiated this record |
| `register_ref` | REQUIRED | `question_id` of the affected open questions register entry |
| `field` | REQUIRED | The manifest field this decision unblocks |
| `decision_required` | REQUIRED | One sentence naming the choice to be made |
| `options` | REQUIRED | List of option objects; each with: `option_id`, `description`, `implication` |
| `requested_at` | REQUIRED | ISO 8601 datetime with timezone |
| `responded_at` | REQUIRED once answered | ISO 8601 datetime with timezone |
| `selected_decision` | REQUIRED once answered | `human:director`'s chosen option ID or free-text value |
| `decision_statement` | REQUIRED once answered | Verbatim from `human:director`'s response |
| `resolved_value` | REQUIRED once answered | The manifest field value this decision produces |
| `resolution_status` | REQUIRED | `AWAITING_DECISION` \| `DECISION_MADE` \| `DEFERRED` \| `UNCLEAR` |

**Process state when a DR record is created:**
- The register entry for the affected BLOCKER gap is updated: `resolution_status: AWAITING_DECISION`, `decision_request_ref: DR-[step]-[seq]`
- The step enters `AWAITING_DECISION` state for this entry
- Other BLOCKER entries are not affected — FC-3 continues in parallel for them
- The step's final blocking condition (no remaining open BLOCKER entries) cannot be satisfied while any entry is in `AWAITING_DECISION`
- The process does not downgrade the entry, proceed past it, or set a timeout

**Unblock condition — response classifications:**

| Response | Classification | Action |
|---|---|---|
| `human:director` names an option or provides a specific value | `DECISION_MADE` | DR record closed; register entry updated to `RESOLVED` with `resolved_value` populated; FC-3 traceability entry written with `source_type: clarification_answer` citing the `DR-xx` ID |
| `human:director` explicitly defers | `DEFERRED` | DR record closed; register entry updated to `CONFIRMED_UNKNOWN`; gap downgraded from BLOCKER per FC-2 rules. Explicit deferral is a conscious choice — it satisfies L2. |
| `human:director`'s response is ambiguous | `UNCLEAR` | Follow-up question sent; `responded_at` not set until a classifiable response arrives |

Note: silence is not deferral. A DR record in `AWAITING_DECISION` with no `responded_at` is still blocking — the step does not proceed.

**What FC-9 does not govern:**
- **Design preferences** — FC-9 presents options to support a decision; it does not gather preferences about things `human:director` has already decided
- **Scope additions** — if `human:director`'s decision reveals new scope not in the brief, that is a scope change requiring a correction path, not an FC-9 resolution
- **Multi-step deferral** — if `human:director` defers a decision at Step 1, the FC-8 carry-forward protocol governs reclassification at subsequent steps; if the gap is still BLOCKER at Step 2, FC-9 is re-invoked at Step 2

**Executor boundaries:**
- Must not recommend an option — presenting is support; recommending is scope-setting
- Must not invent options not grounded in the knowledge base or the brief
- Must not treat silence as implicit deferral and proceed past an `AWAITING_DECISION` entry
- Must not invoke FC-9 for a gap FC-3 could resolve — FC-9 is triggered only when `human:director` has explicitly stated the decision is unmade

***

## FC-10 — Bootstrap Lifecycle State Machine

### Context

Steps 5 and 6 reference a bootstrap lifecycle state — `BOOTSTRAP_ACTIVE`, `CLOSED` — without a formally defined state machine. Step 6 references `AWAITING_REMEDIATION` implicitly. The smoke test references state transitions without a defined initial state. The complete state machine needs to be defined before any of these steps can be implemented.

### Decision Options

**A — Minimal state machine:** Only the states explicitly referenced in the policies (`ACTIVE`, `AWAITING_DECISION`, `CLOSED`).
**B — Full state machine:** All states including intermediate and terminal failure states, with all valid transitions.
**C — Phase-aware state machine:** States that reflect the granular step-level progress, not just the phase-level lifecycle.

### Decision: Option B

Option A is too coarse — it does not account for `AWAITING_REMEDIATION` (Step 6 returns items) or the entry state. Option C is too granular — individual step progress is tracked within each step's policy; the bootstrap lifecycle state machine operates at the phase level. Option B provides a complete, implementable state machine that is specific enough to be governed without tracking implementation detail.

### The Rule

**States:**

| State | Meaning |
|---|---|
| `NOT_STARTED` | The bootstrap phase has not begun. The toolkit exists; no project-specific work has been initiated. |
| `IN_PROGRESS` | The bootstrap phase is actively running. One or more steps are in progress, awaiting completion, or awaiting remediation from a prior attempt. |
| `AWAITING_DECISION` | Step 5 has produced a bootstrap report with a `PASS` or `PASS_WITH_GAPS` verdict. Step 6 has not yet received `human:director`'s decision. |
| `AWAITING_REMEDIATION` | Step 6 produced a `RETURNED_WITH_ITEMS` decision. Specific items have been routed to prior steps. The phase is paused pending remediation completion and a new Step 5 report. |
| `CLOSED` | Step 6 produced an `APPROVED` decision. The bootstrap phase is complete. Delivery work may begin. This is a terminal state — it cannot be exited. |

**Valid transitions:**

| From | To | Trigger | Actor |
|---|---|---|---|
| `NOT_STARTED` | `IN_PROGRESS` | Step 1 begins processing the first project brief | System (first Step 1 action) |
| `IN_PROGRESS` | `AWAITING_DECISION` | Step 5 produces a report with verdict `PASS` or `PASS_WITH_GAPS` | System (Step 5 completion) |
| `AWAITING_DECISION` | `IN_PROGRESS` | Step 6 has not yet acted; `human:director` requests a revision before deciding — treated as an informal return; Step 5 re-runs | Step 6 / `human:director` |
| `AWAITING_DECISION` | `AWAITING_REMEDIATION` | Step 6 produces `RETURNED_WITH_ITEMS` decision | `human:director` |
| `AWAITING_DECISION` | `CLOSED` | Step 6 produces `APPROVED` decision | `human:director` |
| `AWAITING_REMEDIATION` | `IN_PROGRESS` | All returned items are addressed; Step 5 is re-initiated | System (remediation completion) |

**Invalid transitions — explicitly blocked:**

| Attempted transition | Reason blocked |
|---|---|
| `IN_PROGRESS → CLOSED` | Cannot skip Step 5 and Step 6 |
| `AWAITING_DECISION → AWAITING_DECISION` | Not a transition — already in this state |
| `CLOSED → any state` | `CLOSED` is terminal — cannot be exited |
| `NOT_STARTED → AWAITING_DECISION` | Cannot reach AWAITING_DECISION without running IN_PROGRESS |

**Audit log requirements per transition:**
Every state transition produces an audit log entry containing:
- `action_type`: `bootstrap_state_transition`
- `from_state`: the prior state
- `to_state`: the new state
- `trigger`: the event that caused the transition
- `actor`: the identity responsible (system or named human)
- `timestamp`: ISO 8601 with timezone

**The `FAILED` terminal state (deferred):**
The policies do not define a maximum number of `AWAITING_REMEDIATION → IN_PROGRESS` cycles before the bootstrap phase is considered permanently failed. F27 flags this as a framework-level decision. Until that decision is made, the state machine has no terminal failure state — the phase loops between `IN_PROGRESS`, `AWAITING_DECISION`, and `AWAITING_REMEDIATION` until it reaches `CLOSED`. This is a known gap, documented in the open questions register as `OQ-FC-01`.

**System enforcement:**
The Nexus policy engine is the authority for state transitions. Transition requests are validated against the valid transitions table above. Invalid transitions are rejected with a reason code and audit entry. The bootstrap lifecycle state is stored in the Nexus database, not in a document — it is a system state, not a file state.

***

## Cross-Cutting Policies — Dependency Map

For agent designers, the dependencies between these nine policies and the step policies are:

| Policy | Used by steps | Must be decided before |
|---|---|---|
| FC-1 No-invention | 1, 2, 3, 4 | All executor role designs |
| FC-2 Gap taxonomy | 1, 2, 3, 4 | All step skill files |
| FC-3 Clarification protocol | 1, 2 | Step 1 and 2 executor designs |
| FC-4 Approval record pattern | 1, 6 | Step 1 and 6 agent designs |
| FC-5 Traceability record | 1, 2, 3, 4 | All executor role designs |
| FC-6 Verifiability standard | 2, 4, 5 | Step 2 executor, Step 4 reviewer, Step 5 verifier |
| FC-7 Producer/verifier separation | All | All reviewer role designs; Nexus server tool design |
| FC-8 Open questions carry-forward | 1, 2, 3, 4, 5, 6 | All gap analysis tasks across all steps |
| FC-9 Decision support protocol | 1, 2 | Step 1 and 2 executor designs; FC-3 and FC-8 |
| FC-10 Bootstrap state machine | 5, 6 | Step 5 smoke test design; Step 6 task 6.3 |

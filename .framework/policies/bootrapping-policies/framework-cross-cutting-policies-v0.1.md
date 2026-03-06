# Framework Cross-Cutting Policies

**Version:** 0.1 — Draft
**Scope:** Bootstrap phase. Applies to all six step policies. Will be confirmed against delivery lifecycle policies before finalisation.
**Status:** Awaiting review

***

## Purpose

These nine policies settle the cross-cutting behavioural contracts that every bootstrap step and every agent operating within it must implement consistently. They are not step-specific — they are the shared rules that make the step policies coherent as a system rather than a collection of independent documents.

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

**Resolution statuses (terminal states of a BLOCKING gap):**

| Status | Meaning |
|---|---|
| `BLOCKING_RESOLVED` | A BLOCKING gap that was resolved through the clarification protocol. The resolved value is now in the step output. |
| `BLOCKING_CONFIRMED_UNKNOWN` | A BLOCKING gap where `human:director` confirmed they cannot provide the information. Downgraded to `OPEN_QUESTION` with this status recorded. The step output documents it as an open question rather than an empty field. |

**`open_questions` entry schema** — used wherever gaps are documented in step outputs:

| Field | Requirement | Format |
|---|---|---|
| `question_id` | REQUIRED | `OQ-[step]-[sequence]`, e.g., `OQ-1-03` |
| `field` | REQUIRED | The output field this gap relates to |
| `gap` | REQUIRED | What is missing or ambiguous — one sentence |
| `impact` | REQUIRED | What fails or degrades downstream if this remains unresolved |
| `classification` | REQUIRED | `WARNING` or `LOW_RISK` for open questions in a completed step output; `BLOCKING_CONFIRMED_UNKNOWN` for confirmed unknowns |
| `source_step` | REQUIRED | Which step raised this question |
| `resolution_status` | REQUIRED | `UNRESOLVED`, `RESOLVED`, or `CONFIRMED_UNKNOWN` |

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

**Grouping for presentation:**
Questions are grouped by domain in presentation order:

1. Project identity gaps (project name, description)
2. Technical gaps (tech stack, deployment, environment)
3. Governance gaps (human actors, roles)
4. Scope gaps (appetite, out-of-scope, constraints)

Within each group, questions are listed as a numbered list. The group heading names the domain.

**The clarification exchange record** — filed at `[project-root]/.framework/clarifications/step-[n]-clarification-[sequence].md`:

| Field | Requirement | Format |
|---|---|---|
| `exchange_id` | REQUIRED | `CE-[step]-[sequence]`, e.g., `CE-1-01` |
| `step` | REQUIRED | Which step initiated this exchange |
| `initiated_at` | REQUIRED | ISO 8601 datetime with timezone |
| `questions` | REQUIRED | List of question objects; each with: `question_id`, `field`, `question_text`, `impact_statement` |
| `responded_at` | REQUIRED once answered | ISO 8601 datetime with timezone |
| `responses` | REQUIRED once answered | List of response objects; each with: `question_id`, `response_text`, `resolution` (`RESOLVED` \| `CONFIRMED_UNKNOWN`) |

**Behaviour after the exchange:**
- `RESOLVED`: the response provides the required value. The value is written to the step output with `source_type: clarification_answer` in the traceability record, citing the `exchange_id` and `question_id`.
- `CONFIRMED_UNKNOWN`: `human:director` has confirmed they cannot provide this information. The gap is reclassified to `BLOCKING_CONFIRMED_UNKNOWN` and downgraded to an `OPEN_QUESTION` entry in the step output. The step proceeds without this value.

**What the exchange does not do:**
- Does not ask for design preferences ("What colour scheme do you prefer?")
- Does not ask scope-setting questions ("Should we include a blog?") — scope is human:director's domain, not the step's
- Does not offer options ("Should it be AstroJS or Next.js?") — the clarification protocol resolves missing declared information, not undecided information. Undecided technical choices are a Step 1 gap to surface, not to resolve

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

### The Rule

**Tier 1 — Standard Approval** (used in Step 1 and Step 2):

*Applied when:* A document is being confirmed as accurate by the party whose intent it represents. The decision is reversible — the document can be revised and re-approved.

*Fields required in the primary document:*

| Field | Requirement | Format |
|---|---|---|
| `status` | REQUIRED | `APPROVED` — set only by the approval action, never by the producer |
| `approved_by` | REQUIRED | Name of the approving human — must match a named `human:director` entry |
| `approved_at` | REQUIRED | ISO 8601 datetime with timezone — timestamp of the approval action |

*Audit log entry required:*

| Field | Requirement |
|---|---|
| `action_type` | `document_approved` |
| `document` | Path to the approved document |
| `actor` | `approved_by` value |
| `timestamp` | `approved_at` value |
| `document_version` | The version or status of the document at time of approval |

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

**Schema** — each entry is one row:

```
| output_field | value_summary | source_type | source_reference |
```

- `output_field`: exact field name from the primary document schema
- `value_summary`: first 30 characters of the field value, or `[list: N entries]` for list fields
- `source_type`: one of `brief` | `clarification_answer` | `manifest_field` | `contract_field` | `seeding_resource` | `derivation_rule` | `not_present_in_input`
- `source_reference`: specific locator — paragraph identifier, clarification exchange ID + question ID, field path (`manifest.tech_stack[0]`), named seeding resource entry ID, or derivation rule name

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

**The open questions register:**
Filed at `[project-root]/.framework/open-questions-register.md`

Created in Step 1, Task 1.2 (Gap Classification). Persists throughout all six steps. Each step reads it at the start of its gap analysis task and writes to it when producing new open questions or reclassifying existing ones.

**Register entry schema:**

| Field | Requirement | Format |
|---|---|---|
| `question_id` | REQUIRED | `OQ-[step_raised]-[sequence]`, e.g., `OQ-1-03` — never changes after assignment |
| `field` | REQUIRED | The output field this question relates to, including the document it belongs to |
| `gap` | REQUIRED | What is missing or ambiguous — one sentence — never modified after first write |
| `impact` | REQUIRED | What fails or degrades downstream — updated when a subsequent step provides a more specific impact |
| `raised_by_step` | REQUIRED | The step number that first identified this gap |
| `current_owner` | REQUIRED | The step number currently responsible for monitoring or resolving this question |
| `classification` | REQUIRED | `WARNING` \| `LOW_RISK` \| `BLOCKING_CONFIRMED_UNKNOWN` — updated when reclassified |
| `resolution_status` | REQUIRED | `UNRESOLVED` \| `RESOLVED` \| `CONFIRMED_UNKNOWN` |
| `resolution_note` | Conditional | Required when `resolution_status: RESOLVED` — records what resolved it (clarification exchange ID, or "addressed in Step N output") |
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

**The register at Step 6:**
The bootstrap report (Step 5) includes the register's `UNRESOLVED` entries in its gap list. Step 6 presents these to `human:director`. Gap acknowledgements in the Step 6 decision record reference `question_id` values from the register — not free-text descriptions. After Step 6 `APPROVED`, entries with `resolution_status: UNRESOLVED` that `human:director` acknowledged are updated to `resolution_status: ACCEPTED_AS_KNOWN_GAP`.

***

## FC-9 — Bootstrap Lifecycle State Machine

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
| FC-9 Bootstrap state machine | 5, 6 | Step 5 smoke test design; Step 6 task 6.3 |